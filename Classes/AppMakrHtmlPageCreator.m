//
//  AppMakrHtmlPageCreator.m
//  appbuildr
//
//  Created by Sergey Popenko on 12/22/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "AppMakrHtmlPageCreator.h"

@implementation AppMakrHtmlPageCreator

@synthesize html;

-(BOOL) loadTemplate: (NSString*) filePath
{
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if(readHandle == nil)
    {
        return NO;
    }
    
    html = [[NSMutableString alloc] init];
    [html appendFormat: @"%@", [[[NSString alloc] initWithData: 
                                 [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding] autorelease]];  
    return YES;
}

-(void)dealloc
{
    [html release]; html = nil;
    [super dealloc];
}

-(void) addInformation: (NSString*) info forTag: (NSString*) tag
{
    [html replaceOccurrencesOfString: tag withString:info options:NSLiteralSearch range:NSMakeRange(0, [html length])];
}

@end
