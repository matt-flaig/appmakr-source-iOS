//
//  UITapGestureRecognizer+SingleTap.m
//  appbuildr
//
//  Created by Sergey Popenko on 11/14/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "UITapGestureRecognizer+SingleTap.h"

@implementation UITapGestureRecognizer (SingleTap)

+(UITapGestureRecognizer*) createSingleTapRecognizerWithTarget:(id)target action: (SEL)action
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: target
                                                                                    action: action];
 	tapRecognizer.numberOfTapsRequired = 1;
	tapRecognizer.cancelsTouchesInView = NO;
    tapRecognizer.delegate = target;
    return [tapRecognizer autorelease];
}
@end
