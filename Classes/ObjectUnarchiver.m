//
//  UnArchiver.m
//  appbuildr
//
//  Created by Isaac Mosquera on 5/6/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ObjectUnarchiver.h"
#import "MD5.h"
@implementation ObjectUnarchiver


-(void) dealloc {
	[super dealloc];
}
+ (NSObject *) getObjectWithName:(NSString*) theName 
{
	if (theName == nil || ([theName length] <=0)) 
	{
		return nil;
	}
	
	NSString * directory = @"archived_objects";
	NSString * md5Name = [MD5 hash:theName];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * filePath = [documentsDirectory stringByAppendingFormat:@"/%@/%@", directory, md5Name] ;
	NSObject * newObject = (NSObject *)[NSKeyedUnarchiver unarchiveObjectWithFile: filePath];
	return newObject;
}
@end
