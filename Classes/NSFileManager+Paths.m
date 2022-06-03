//
//  NSFileManager+Paths.m
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 5/25/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import "NSFileManager+Paths.h"


@implementation NSFileManager(Paths)

- (NSString*) pathForResource:(NSString*)resource{
	return [[NSBundle mainBundle] pathForResource:resource ofType:nil];
}

- (NSString*) pathForAppData:(NSString*)data{
	NSString* documentFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	return [documentFolder stringByAppendingPathComponent:data];
}

@end
