//
//  PointAboutNavigationController.h
//  appbuildr
//
//  Created by William Johnson on 12/20/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "PointAboutTabBarScrollViewController.h"
#import "PointAboutViewControllerProtocol.h"
@interface PointAboutNavigationController : UINavigationController <PointAboutViewControllerProtocol>
{
	PointAboutTabBarScrollViewController *pointAboutTabBarScrollViewController;
	UIButton							 *tabBarButton;
}

@property (nonatomic, retain) PointAboutTabBarScrollViewController * pointAboutTabBarScrollViewController;
@property (nonatomic, readonly) UIButton *tabBarButton;


@end
