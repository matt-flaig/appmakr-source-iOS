//
//  NSError+Creation.h
//  XMLParser
//
//  Created by Rolf Hendriks on 3/31/10.
//  Copyright 2010 PointAbout Inc. All rights reserved.
//

@interface NSError(Creation)

+ (NSError*) errorWithMessage:(NSString*)message, ...;
+ (NSError*) errorWithMessage:(NSString*)message containingError:(NSError*)error;
+ (NSError*) errorWithValue:(id)value forKey:(NSString*)key;

@end
