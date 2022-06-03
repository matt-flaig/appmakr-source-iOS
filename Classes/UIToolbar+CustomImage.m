//
//  UIToolbar+CustomImage.m
//  appbuildr
//
//  Created by Sergey Popenko on 11/29/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "UIToolbar+CustomImage.h"


@implementation UIToolbar (CustomImage)
-(void)setToolbarBack:(NSString*)bgFilename
{
    // Add Custom Toolbar
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:bgFilename]];
    iv.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // Add the tab bar controller's view to the window and display.
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5)
        [self insertSubview:iv atIndex:1]; // iOS5 atIndex:1
    else
        [self insertSubview:iv atIndex:0]; // iOS4 atIndex:0
    self.backgroundColor = [UIColor clearColor];
}
@end