//
//  NSError+Creation.m
//  XMLParser
//
//  Created by Rolf Hendriks on 3/31/10.
//  Copyright 2010 PointAbout Inc. All rights reserved.
//

#import "NSError+Creation.h"

#define kDefaultDomain @"TDS Kiosk"
#define kDefaultErrorCode 1

@implementation NSError(Creation)

+ (NSError*) errorWithMessage:(NSString*)message, ...{
	va_list args;
	va_start (args, message);
	NSString* messageResolved = [[NSString alloc] initWithFormat:message arguments:args];
	NSError* result = [NSError errorWithDomain:kDefaultDomain code:kDefaultErrorCode userInfo:
					   [NSDictionary dictionaryWithObject:messageResolved forKey:NSLocalizedDescriptionKey]];
	va_end(args);
	[messageResolved release];
	return result;
}

+ (NSError*) errorWithMessage:(NSString*)message containingError:(NSError*)error{
	return [NSError errorWithDomain:kDefaultDomain code:kDefaultErrorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
		message, NSLocalizedDescriptionKey, error, NSUnderlyingErrorKey, nil]];
}

+ (NSError*) errorWithValue:(id)value forKey:(NSString*)key{
	return [NSError errorWithDomain:kDefaultDomain code:kDefaultErrorCode userInfo:
			[NSDictionary dictionaryWithObject:value forKey:key]];
}

@end
