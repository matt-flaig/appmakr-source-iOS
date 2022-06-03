//
//  PointAboutTableViewController.h
//  Kaplan
//
//  Created by William M. Johnson on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PointAboutViewControllerProtocol.h"

@class PointAboutTabBarScrollViewController;
@interface PointAboutTableViewController : UITableViewController <PointAboutViewControllerProtocol>
{

	@package
	PointAboutTabBarScrollViewController * pointAboutTabBarScrollViewController;
	UIButton *tabBarButton;
}

//@property (nonatomic, retain) PointAboutTabBarScrollViewController * pointAboutTabBarScrollViewController;
//@property (nonatomic, readonly) UIButton *tabBarButton;
@end
