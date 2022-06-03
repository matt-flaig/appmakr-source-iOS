//
//  Archiver.m
//  appbuildr
//
//  Created by Isaac Mosquera on 5/5/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ObjectArchiver.h"
#import "MD5.h"

@implementation ObjectArchiver
NSString * directory = @"archived_objects";

-(void) dealloc {
	[object release];
	[super dealloc];
}
- (id) initWithObject:(NSObject *)theObject name:(NSString *)name {
	if ( (self = [super init]) ) {
		object = [theObject retain];
		NSString * objectName = [MD5 hash:name];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString * filePath = [documentsDirectory stringByAppendingFormat:@"/%@/%@", directory, objectName];
		DebugLog(@"%@ archiving object to path: %@", name, filePath);
		[NSThread detachNewThreadSelector:@selector(startBackgroundArchiveWrite:)
								 toTarget:self
							   withObject:filePath];
	}
	return self;
}

-(void) startBackgroundArchiveWrite:(NSString *)filePath {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc]init];
	NSFileManager * fileMgr = [NSFileManager defaultManager];
	NSString * dirPath = [filePath stringByDeletingLastPathComponent];
	if( ![fileMgr fileExistsAtPath:dirPath] ) {
		[fileMgr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
//	NSData * data = (NSData *)object;
//	[data writeToFile:filePath atomically:YES];

	if( ![NSKeyedArchiver archiveRootObject:object toFile:filePath] ) {  // write object to file
		DebugLog(@"Write Object Failed.");
	}
	[pool release];
}

+(void) removeAllArchivedData{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	documentsDirectory = [documentsDirectory stringByAppendingString:@"/%@/"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:documentsDirectory error:NULL];
}


@end
