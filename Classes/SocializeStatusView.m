//
//  SocializeSwipeUpView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeStatusView.h"

@implementation SocializeStatusView

- (void) dealloc 
{	
	[audioPlayer dealloc];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)aRect 
{
	self = [super initWithFrame:aRect];
	self.backgroundColor = [UIColor clearColor];
	
	audioPlayer = [AMAudioPlayerViewController sharedInstance];

	//audioPlayer.view.hidden = YES;
	[self addSubview: audioPlayer.view];
	
	UIScreen* mainScreen = [UIScreen mainScreen];
	CGRect currentFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, mainScreen.bounds.size.width,
											audioPlayer.view.frame.size.height);
	self.frame = currentFrame;
							
	return self;	
}
- (void)layoutSubviews {
	DebugLog(@"laying out subviews for socialize swipe up view");
	audioPlayer.view.frame = CGRectMake(0, 0,
								 audioPlayer.view.frame.size.width, audioPlayer.view.frame.size.height);
	
	//THIS SHOULD DO ALL THE MATH TO RECALCULATE THE FRAME SIZE TO FIT ALL THE ELEMENTS THAT ARE CURRENTLY
	//BEING SHOWN, LIKE THE MEDIA PLAYER OR NOTIFICATIONS.
	/*
	self.frame = CGRectMake(swipeImageView.frame.origin.x, swipeImageView.frame.origin.y,
							swipeImageView.frame.size.width,swipeImageView.frame.size.height);
	 */
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
							self.frame.size.width, audioPlayer.view.frame.size.height);

}
@end
