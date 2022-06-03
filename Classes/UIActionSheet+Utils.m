//
//  UIActionSheet+Utils.m
//  appbuildr
//
//  Created by Sergey Popenko on 3/22/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "UIActionSheet+Utils.h"

@implementation UIActionSheet (Utils)
-(BOOL) removeBtnWithTitle:(NSString*)title
{
    NSMutableArray* buttons = (NSMutableArray*)[self valueForKey:@"_buttons"];
    
    __block UIButton* removeBtn = nil;
    [buttons enumerateObjectsUsingBlock:^(id btn, NSUInteger idx, BOOL* stop)
     {       
         if ([[btn title] isEqualToString:title]) 
         {
             removeBtn = btn;
         }
     }
     ];
    
    [removeBtn removeFromSuperview];
    [buttons removeObject:removeBtn];
    
    self.cancelButtonIndex = [buttons count] -1;
    return (removeBtn != nil) ? YES : NO;
}
@end
