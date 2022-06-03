//
//  AppMakrHtmlPageCreator.h
//  appbuildr
//
//  Created by Sergey Popenko on 12/22/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppMakrHtmlPageCreator : NSObject {
    NSMutableString* html;
}

-(BOOL) loadTemplate: (NSString*) filePath;
-(void) addInformation: (NSString*) info forTag: (NSString*) tag;

@property (nonatomic, readonly) NSString* html;

@end
