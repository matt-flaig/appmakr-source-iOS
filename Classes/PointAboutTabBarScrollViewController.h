//
//  PointAboutTabBarScrollViewController.h
//  Kaplan
//
//  Created by William M. Johnson on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterController.h"

@class PointAboutTabBarScrollView;

typedef enum {
	POINTABOUT_TABBAR_DISPLAY_ICON,
	POINTABOUT_TABBAR_DISPLAY_TEXT,
} PointAboutTabBarDisplayType;



@interface PointAboutTabBarScrollViewController:MasterController <UIScrollViewDelegate>
{
	
	@private
		PointAboutTabBarScrollView * pointAboutTabBarScrollView;
		UIColor			 *tabBarBackgroundColor;
		NSArray			 *viewControllers;
		NSMutableArray	 *tabBarButtons;
		UIButton		 *selectedButton;
		UIViewController *selectedViewController;
		UIImageView		 *tmaRightView;
		UIImageView		 *blankImageView;
		UIImageView		 *tabBarBackgroundImageView;
		UIImageView		 *tmaLeftView;
		UIImageView		 *leftBlankImageView;
		PointAboutTabBarDisplayType displayType;
		bool displayTop;
}

@property (nonatomic, readonly) PointAboutTabBarScrollView * pointAboutTabBarScrollView;
@property (nonatomic, retain)   UIImageView *tabBarBackgroundImageView;
@property (nonatomic) bool	displayTop;
@property (nonatomic) PointAboutTabBarDisplayType displayType;
@property (nonatomic, retain) UIColor *tabBarBackgroundColor;
@property (nonatomic, retain) NSArray* viewControllers;
@property (nonatomic, retain) NSArray* tabBarButtons;

-(id)initWithViewControllers:(NSArray *)vControllers displayType:(PointAboutTabBarDisplayType)tabBarDisplayType displayTop:(bool)tabBarDisplayTop;
-(void)resize;
-(void)hideTabBar;
-(void)unHideTabBar;
-(void)selectTheProfileView;
-(void)selectTheActivityView;

@end
