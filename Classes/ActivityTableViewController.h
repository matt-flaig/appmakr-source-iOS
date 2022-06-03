//
//  ActivityTableViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/24/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityTableViewCell.h"
#import "PointAboutTableViewController.h"
#import "AppMakrSocializeService.h"
#import "AppMakrTableBGInfoView.h"

@interface ActivityTableViewController : PointAboutTableViewController <AppMakrSocializeServiceDelegate>
{
	BOOL					showProfileImages;
	ActivityTableViewCell	*activityTableCell;
	NSArray					*activitiesArray;
	NSMutableDictionary		*userImageDictionary;
	AppMakrTableBGInfoView			*informationView;
}

@property (nonatomic) BOOL					 showProfileImages;
@property (nonatomic, retain) AppMakrTableBGInfoView *informationView;
@property (nonatomic, assign) IBOutlet ActivityTableViewCell *activityTableCell;
@property (nonatomic, retain) NSArray			  *activitiesArray;
@property (nonatomic, retain) NSMutableDictionary *userImageDictionary;

-(IBAction)viewProfileButtonTouched:(id)sender;


@end
