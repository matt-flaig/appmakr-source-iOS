//
//  SendMessageView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "CustomActivityView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomActivityView

- (void) dealloc {
	[indicatorView release];
	[labelView release];
	[super dealloc];
}
- (id)initWithTitle:(NSString *)title {
	if( (self = [super init]) ) {
		indicatorView = [[UIActivityIndicatorView alloc] init];
		[indicatorView startAnimating];
		labelView = [[UILabel alloc] init];
		labelView.text = title;
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
- (void)layoutSubviews {
	float locX = (self.frame.size.width/2) - 10;
	float locY = (self.frame.size.height/2) - 10;
	indicatorView.frame = CGRectMake(locX, locY, 25, 25);
	NSInteger labelWidth = self.frame.size.width-20;
	NSInteger centerX = (self.frame.size.width - labelWidth)/2;
	labelView.frame = CGRectMake(centerX,10,labelWidth,30);
}

@end
