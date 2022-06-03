//
//  NSFileManager+Metadata.m
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 6/3/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import "NSFileManager+Metadata.h"

NSString* const kLastModifiedDateKey = @"NSFileModificationDate";

@implementation NSFileManager(Metadata)

- (NSDate*) lastModifiedDateForPath:(NSString*)filePath error:(NSError**)error{
	NSDictionary* attributes = [self attributesOfItemAtPath:filePath error:error];
	if (error)
		return nil;
	
	return [attributes objectForKey:kLastModifiedDateKey];
}

@end
