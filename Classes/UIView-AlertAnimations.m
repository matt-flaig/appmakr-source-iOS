//
//  UIView-AlertAnimations.m
//  Custom Alert View
//
//  Created by jeff on 5/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration  0.2555

@implementation UIView(AlertAnimations)
- (void)doPopInAnimation
{
    [self doPopInAnimationWithDelegate:nil];
}
- (void)doPopInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:.3],
                             [NSNumber numberWithFloat:.7],
                             [NSNumber numberWithFloat:1],
                             nil];
	
	
	
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.3],
                               [NSNumber numberWithFloat:0.7],
                               [NSNumber numberWithFloat:1.0], 
                               nil];    
	popInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    popInAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scaleIn"];  
}

- (void)doPopOutAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	
	self.layer.transform = CATransform3DMakeScale(.1, .1, .1);  
	
	popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:1.0],
                             [NSNumber numberWithFloat:.7],
                             [NSNumber numberWithFloat:.3],
                             [NSNumber numberWithFloat:.1],
                             nil];
    
	popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.3],
                               [NSNumber numberWithFloat:0.7],
                               [NSNumber numberWithFloat:1.0], 
                               nil];    
    popInAnimation.delegate = animationDelegate;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scaleOut"];  
}

- (void)doFadeInAnimation
{
    [self doFadeInAnimationWithDelegate:nil];
}
- (void)doFadeInAnimationWithDelegate:(id)animationDelegate
{
    CALayer *viewLayer = self.layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = animationDelegate;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}
@end
