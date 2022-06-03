//
//  LikesTableViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointAboutViewController.h"
#import "Entry.h"
#import "Feed.h"
#import "AppMakrSocializeService.h"
#import "AppMakrTableBGInfoView.h"
#import "MasterController.h"

@interface LikesTableViewController : MasterController <FeedServiceDelegate, AppMakrSocializeServiceDelegate, 
				UITableViewDelegate, UITableViewDataSource>{

	IBOutlet UITableView	*_tableView;
	Feed				*likesFeed;
	AppMakrSocializeService	*socializeService;
	NSArray				*entriesArray;
	AppMakrTableBGInfoView		*informationView;
}

@property(nonatomic, retain) Feed			*likesFeed;
@property(nonatomic, retain) FeedService	*socializeService;
@property(nonatomic, retain) NSArray		*entriesArray;
@property(nonatomic, retain) IBOutlet UITableView	*_tableView;

-(void) updateLikesTableView;

@end
