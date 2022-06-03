//
//  UIView+RoundedCorner.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "UIView+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RoundedCorner)

-(BOOL)setRoundedCornerOnHierarchy:(CGFloat)radius{
	[[self layer] setCornerRadius:radius];

	for (UIView* view in [self subviews]) {
		[view setRoundedCornerOnHierarchy:radius];
	}
	return YES;
}

@end
