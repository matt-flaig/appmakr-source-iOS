//
//  FeedArchiver.m
//  appbuildr
//
//  Created by Isaac Mosquera on 10/5/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "FeedArchiver.h"
#import "MD5.h"


@implementation FeedArchiver
@synthesize feed;

-(void) dealloc {
	[feed release];
	[super dealloc];
}
- (void) archiveWithFeed:(Feed *)newFeed title:(NSString *)aTitle {
	
	//title = [aTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	title = [MD5 hash:aTitle];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingFormat:@"/feed_archives/%@", title];
	 
	self.feed = newFeed;
	[NSThread detachNewThreadSelector:@selector(startBackgroundArchiveWrite:)
							 toTarget:self
						   withObject:filePath];
}
-(void) startBackgroundArchiveWrite:(NSString *)filePath {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	@synchronized(feed) {
		NSFileManager * fileMgr = [NSFileManager defaultManager];
		NSString * dirPath = [filePath stringByDeletingLastPathComponent];
		if( ![fileMgr fileExistsAtPath:dirPath] ) {
			[fileMgr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if( ![NSKeyedArchiver archiveRootObject:self.feed toFile:filePath] ) {  // write object to file
			DebugLog(@"Write Object Failed.");
		}
	}
	[pool release];
}


- (Feed *) unarchiveWithTitle:(NSString*) aTitle {
	//title = [aTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	title = [MD5 hash:aTitle];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingFormat:@"/feed_archives/%@", title];
	
	if ( filePath ==nil) { return nil; }
	self.feed = (Feed *)[NSKeyedUnarchiver unarchiveObjectWithFile: filePath];
	return self.feed;	
}

+(void) removeAllArchivedData{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	documentsDirectory = [documentsDirectory stringByAppendingString:@"/feed_archives/"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:documentsDirectory error:NULL];
}


@end
