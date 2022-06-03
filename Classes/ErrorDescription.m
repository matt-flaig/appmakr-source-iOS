//
//  ErrorDescription.m
//  appbuildr
//
//  Created by Sergey Popenko on 11/29/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "ErrorDescription.h"

@implementation ErrorDescription
@synthesize title = _title;
@synthesize body = _body;
-(void)dealloc
{
    self.title = nil;
    self.body = nil;
    [super dealloc];
}

+(ErrorDescription*)descriptionWithTitle:(NSString*)title body:(NSString*)body
{
    ErrorDescription* desription = [[ErrorDescription alloc] init];
    desription.title = title;
    desription.body = body;
    return [desription autorelease];
}
@end
