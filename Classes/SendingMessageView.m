//
//  SendMessageView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SendingMessageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SendingMessageView

@synthesize labelView;

- (void) dealloc {
	[indicatorView release];
	[labelView release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)aRect {
	if( (self = [super initWithFrame:aRect]) ) {
		float locX = (aRect.size.width/2) - 10;
		float locY = (aRect.size.height/2) - 10;
		indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(locX, locY, 25, 25)];
		[indicatorView startAnimating];
		NSInteger labelWidth = aRect.size.width-20;
		NSInteger centerX = (aRect.size.width - labelWidth)/2;
		labelView = [[UILabel alloc] initWithFrame:CGRectMake(centerX,10,labelWidth,30)];
		labelView.text = @"Sending Message";
		labelView.adjustsFontSizeToFitWidth	= YES;
		labelView.textColor = [UIColor whiteColor];
		labelView.backgroundColor = [UIColor clearColor];
		self.alpha = 0.8f;
		self.backgroundColor = [UIColor blackColor];
		[[self layer] setCornerRadius:12];
		[[self layer] setMasksToBounds:YES];
		
		[self addSubview:labelView];
		[self addSubview:indicatorView];
	}
	return self;
}

@end
