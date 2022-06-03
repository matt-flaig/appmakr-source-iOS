//
//  FeedDataSource.h
//  appbuildr
//
//  Created by Nitin Alabur on 2/11/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "FeedTableViewController.h"

@interface FeedDataSource : NSObject <UITableViewDataSource> {
	FeedTableViewController *tableViewController;
	NSString				*archivePath;
}

-(id)initWithFeedTableViewController:(FeedTableViewController *)feedViewController;

@property(nonatomic, retain) NSString *archivePath;

@end
