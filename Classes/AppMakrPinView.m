//
//  AppMakrPinView.m
//  appbuildr
//
//  Created by Fawad Haider  on 4/11/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrPinView.h"




@implementation AppMakrPinView

@synthesize annotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)didMoveToSuperview {
    /*    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
     animation.duration = 0.4;
     animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
     animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, -400, 0)];
     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
     
     CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
     animation2.duration = 0.10;
     animation2.beginTime = animation.duration;
     animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
     animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DMakeTranslation(0, self.layer.frame.size.height*kDropCompressAmount, 0), 1.0, 1.0-kDropCompressAmount, 1.0)];
     animation2.fillMode = kCAFillModeForwards;
     
     CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"transform"];
     animation3.duration = 0.15;
     animation3.beginTime = animation.duration+animation2.duration;
     animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
     animation3.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
     animation3.fillMode = kCAFillModeForwards;
     
     CAAnimationGroup *group = [CAAnimationGroup animation];
     group.animations = [NSArray arrayWithObjects:animation, animation2, animation3, nil];
     group.duration = animation.duration+animation2.duration+animation3.duration;
     group.fillMode = kCAFillModeForwards;
     
     [self.layer addAnimation:group forKey:nil];
     */
}

//-(void)


- (void)dealloc
{
    self.annotation = nil;
    [super dealloc];
}

@end
