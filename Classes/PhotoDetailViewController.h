//
//  PhotosDetailViewController.h
//  politico
//
//  Created by PointAbout Dev on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "Feed.h"
#import "MasterController.h"
#import "FeedService.h"
#import "AdsControllerDelegate.h"
#define degreesToRadian(x) (M_PI * (x) / 180.0)

@interface PhotoDetailViewController: MasterController <UIScrollViewDelegate, UIActionSheetDelegate, FeedServiceDelegate, AdsControllerCallback> 
{
	Feed * photoFeed;
	NSInteger selectedIndex;
	UIScrollView *scrollView;
	int page;
	int exPageValue;
	NSMutableArray *photoImageViews;
	NSString * tabBarTitle;
	NSMutableDictionary *urlDownloads;
	BOOL isCaptionShowing ;
	FeedService *theFeedService;
    id<AdsController> adsManager;
}
@property NSInteger selectedIndex;
@property(retain) FeedService *theFeedService;

-(id)initWithFeed:(Feed *)feed;
-(id)initWithFeedID:(id)feedID;
@end
