//
//  PATabBarScrollView.m
//  Kaplan
//
//  Created by William M. Johnson on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointAboutTabBarScrollView.h"



@implementation PointAboutTabBarScrollView
@synthesize contentView;
@synthesize tabBarScrollView;
@synthesize displayTop;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
		self.autoresizesSubviews = YES;
        // Initialization code	
		displayTop = false;
		DebugLog(@"%f, %f", frame.size.height, frame.size.width);
		contentView = [[UIView alloc] initWithFrame:frame];
		[self addSubview:contentView];
		
		tabBarScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
		tabBarScrollView.backgroundColor = [UIColor clearColor];
		tabBarScrollView.scrollsToTop = NO;
		[self addSubview:tabBarScrollView];	
	}
    return self;
}

- (void) layoutSubviews {
	CGRect scrollFrame = self.tabBarScrollView.frame;
	if(!displayTop) {
		scrollFrame = CGRectMake( scrollFrame.origin.x,self.frame.size.height - scrollFrame.size.height,
								 self.frame.size.width, scrollFrame.size.height);
		self.tabBarScrollView.frame = scrollFrame;
	}
	CGRect contentFrame = self.contentView.frame;
	contentFrame = CGRectMake( contentFrame.origin.x, contentFrame.origin.y,
							  self.frame.size.width, self.frame.size.height - scrollFrame.size.height);
	self.contentView.frame = contentFrame;
}
- (void)dealloc {
	[tabBarScrollView removeFromSuperview];
	[tabBarScrollView release];
	[contentView removeFromSuperview];
	[contentView release];
    [super dealloc];
}

@end
