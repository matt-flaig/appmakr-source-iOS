//
//  AppMakrDateTimeConvertor.h
//  appbuildr
//
//  Created by Sergey Popenko on 4/5/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppMakrDateTimeConvertor : NSObject

-(id)initWithDestinationFormat:(NSString*)format;

-(NSString*) convertDateTimeString:(NSString*)dtString;
-(NSString*) convertDateTimeString:(NSString *)dtString toFormat:(NSString*)format;

@property(nonatomic, retain) NSString* destinationFormat;

@end
