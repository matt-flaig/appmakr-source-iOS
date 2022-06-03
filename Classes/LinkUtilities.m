//
//  LinkUtilities.m
//  appbuildr
//
//  Created by William Johnson on 11/4/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "LinkUtilities.h"


@implementation LinkUtilities

static NSDictionary* mimeTypes = nil;

+(void) initialize
{
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"mime_types" ofType:@"plist"];
	if (!mimeTypes)
		mimeTypes = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

+(NSString *)getHrefExtension:(NSString *)href
{
	if( !href ) 
	{
		return nil;
	}
	
	NSRange dotRange = [href rangeOfString:@"." options:NSBackwardsSearch];
	if( dotRange.location != NSNotFound ) {
		NSString *extension = [href substringFromIndex:dotRange.location+1];
		return extension;
	}
	return nil;
}

+ (BOOL) hasVideo:(NSString *)href
{
	
	NSString* extension = [self getHrefExtension:href];
	if (!extension ) 
	{
	  return NO;
	} 
	else 
	{
		NSString* fileType = [mimeTypes objectForKey:extension];
		if( [fileType isEqualToString:@"video"] ) 
		{
			return YES;
		}
	}
	return NO;
}



@end
