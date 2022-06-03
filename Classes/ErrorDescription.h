//
//  ErrorDescription.h
//  appbuildr
//
//  Created by Sergey Popenko on 11/29/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorDescription : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* body;
+(ErrorDescription*)descriptionWithTitle:(NSString*)title body:(NSString*)body;

@end
