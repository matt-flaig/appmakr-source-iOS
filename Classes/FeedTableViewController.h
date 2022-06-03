//
//  RootViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 1/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "AppMakrURLDownload.h"
#import "FeedObjects.h"
#import "AdsViewController.h"
#import "ProgressBarView.h"
#import "FeedViewController.h"
#import "MoviePlayerController.h"
#import "SocializeModalViewController.h"

@class SZPathBar;
@interface FeedTableViewController : FeedViewController <UITableViewDelegate,  SocializeModalViewCallbackDelegate>
{	
	UIView				*bottomView;
	UIView				*mediaPlayerView;
	UIActivityIndicatorView* activityIndicator;
	CGSize				cellSize;

	UIColor				*Color;
	UITableView			*tableView;

	NSMutableDictionary *imagesDidDownload;
	NSString			*viewTitle;

	UISegmentedControl  *changePageButton;
	int					currentRow;
	
	bool				youtubeAtRoot;
	bool				feedAtRoot;
	
	UIBarButtonItem		*editButton;
	NSURL				*mediaURL;
    
	SocializeModalViewController	*_modalViewController;
    SZPathBar* bar;
}

@property(nonatomic,retain) UITableView	*tableView;
@property(nonatomic,retain) NSString	*viewTitle;
@property(nonatomic,retain) UIView		*bottomView;
@property(nonatomic,retain) UIView		*mediaPlayerView;
@property(nonatomic,retain) UISegmentedControl *changePageButton;
@property(nonatomic,assign) int					currentRow;

- (id)initWithFeed:(NSString* ) feedUrl title:(NSString*) title;
- (void)pushDescriptionViewWithIndexPath:(NSIndexPath *)indexPath;
- (void)webLinkPressed;
- (void)feedPressed;
- (void)gotoWebpageView:(NSString *) urlString;
- (void)gotoRootView:(NSString *) urlString;
- (void)reloadTableViewDataSource;
//- (void)setSocializeDelegateOnCell:(UITableViewCell*)tableCell;
@end
