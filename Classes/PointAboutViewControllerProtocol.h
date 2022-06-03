//
//  PointAboutViewControllerProtocol.h
//  appbuildr
//
//  Created by William Johnson on 12/17/10.
//  Copyright 2010 pointabout. All rights reserved.//

//#import "PointAboutTabBarScrollViewController.h"

@class PointAboutTabBarScrollViewController;
@protocol PointAboutViewControllerProtocol

@property (nonatomic, retain) PointAboutTabBarScrollViewController * pointAboutTabBarScrollViewController;
@property (nonatomic, readonly) UIButton *tabBarButton;


@end
