//
//  ActivityBaseViewController.h
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointAboutViewController.h"
#import "ActivityTableViewController.h"
#import "AppMakrSocializeService.h"
#import "MasterController.h"

@class ActivityTableViewDelegate;
@interface ActivityBaseViewController: MasterController <AppMakrSocializeServiceDelegate>
{
	IBOutlet ActivityTableViewController *activityTableViewController;
	AppMakrSocializeService					 *theService;
	NSArray								 *activitiesArray;
	
	ActivityTableViewDelegate			 *tableViewDelegate;
	UIActivityIndicatorView				 *activitySpinner;
}

@property (nonatomic, retain) AppMakrSocializeService *theService;
@property (nonatomic, retain) NSArray			*activitiesArray;


@end
