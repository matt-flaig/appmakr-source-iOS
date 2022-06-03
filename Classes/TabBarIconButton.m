//
//  TabBarIconView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "TabBarIconButton.h"


@implementation TabBarIconButton
@synthesize title;


- (void) dealloc 
{
	[titleLabel release];
	[iconImageView release];
    [super dealloc];
}
- (id)initWithTabBarItem:(UITabBarItem *)tabBarItem {
		
	CGRect aRect = CGRectMake(0,0, tabBarItem.image.size.width, tabBarItem.image.size.height);
	if( (self = [super initWithFrame:aRect]) ) {
		iconImageView = [[UIImageView alloc] initWithImage:tabBarItem.image];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.text = tabBarItem.title;

		[self addSubview:iconImageView];
		[self addSubview:titleLabel];
		[self layoutSubviews];
	}
	return self;
}
-(void)layoutSubviews {
	[super layoutSubviews];
	if( titleLabel.text ) {
		CGRect labelFrame = CGRectMake(0, iconImageView.frame.size.height + 5.0f, iconImageView.frame.size.width, 15.0f  );
		titleLabel.frame = labelFrame;	
	} else {
		titleLabel.hidden = YES;
	}
}
-(void)setTitle:(NSString *)theTitle{
	titleLabel.text = theTitle;
}
-(NSString *)title {
	return titleLabel.text;
}
@end
