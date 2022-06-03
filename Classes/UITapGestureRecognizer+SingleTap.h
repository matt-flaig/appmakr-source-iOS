//
//  UITapGestureRecognizer+SingleTap.h
//  appbuildr
//
//  Created by Sergey Popenko on 11/14/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapGestureRecognizer (SingleTap)
    +(UITapGestureRecognizer*) createSingleTapRecognizerWithTarget:(id)target action: (SEL)action;
@end
