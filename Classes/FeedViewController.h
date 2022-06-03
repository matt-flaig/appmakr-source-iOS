//
//  FeedController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/1/10.
//  Copyright 2010 pointabout. All rights reserved.
//


#import "RefreshTableHeaderView.h"
#import "ProgressBarView.h"
#import "Feed.h"
#import "AdsViewController.h"
#import "MasterController.h"
#import "AppMakrSocializeService.h"
#import "AdsControllerDelegate.h"

@interface FeedViewController : MasterController <FeedServiceDelegate, AppMakrSocializeServiceDelegate, AdsControllerCallback> {

	NSString			*rssFeedUrl;
	NSString			*archivePath;
	NSString			*cleanTitle;
	NSString			*feedKey;
	BOOL				beforeAdLoaded;
	BOOL				reloading;
	BOOL				checkForRefresh;
	BOOL				didOnloadRefresh;
	RefreshTableHeaderView *refreshHeaderView;
	ProgressBarView		   *progressBarView;
	UIScrollView		   *_internalScrollView;
	int					   numStories;
	Feed				   *feed;
	id<AdsController>	   adManager;
	AppMakrSocializeService	   *theFeedService;

}

@property(nonatomic, retain) Feed			*feed;
@property(nonatomic, retain) NSString		*rssFeedUrl;
@property(nonatomic, retain) NSString		*feedKey;
@property(nonatomic, retain) UIScrollView	*_internalScrollView;
@property(nonatomic, retain) id<AdsController> adManager;
@property(nonatomic, retain) NSString		   *archivePath;
@property(nonatomic, retain) AppMakrSocializeService  *theFeedService;
@property(nonatomic) BOOL showTopImage;

- (id)initWithFeed:(NSString* ) feedUrl title:(NSString*) title;
- (void)refreshEntries;
- (void)resetRefreshHeader;
	
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)hideProgressBar;
- (void)applyFeedUrl:(NSString *)feedUrl title:(NSString *)title;
- (BOOL) wasConfigurationChanged:(NSDictionary*) configs;
@end
