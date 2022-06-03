//
//  WebpageController.h
//  appbuildr
//
//  Created by PointAboutAdmin on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FeedTableViewController.h"
#import "Feed.h"
#import "Entry.h"
#import "AdsControllerDelegate.h"

@class SocializeModalViewController;
@interface WebpageViewController : UIViewController <UIWebViewDelegate, UINavigationControllerDelegate, AdsControllerCallback> {
	Entry					*entry;
	NSString				*entryURL;
	
	UIWebView				*webpageView;
	UIActivityIndicatorView *progressView;
	UIBarButtonItem			*backButton;
	UIBarButtonItem			*forwardButton;
	UIBarButtonItem			*safariButton;
	UIBarButtonItem			*reloadButton;
	UIToolbar				*toolbar;
	NSString				*parentController;
	bool didResizeFromRotate;
	
	bool toModalView;
	
	int toolBarItemCount;
}

@property(nonatomic, retain) NSString				*entryURL;
@property(nonatomic, retain) UIWebView				*webpageView;
@property(nonatomic, retain) UIBarButtonItem		*reloadButton;
@property(nonatomic, retain) UIActivityIndicatorView *progressView;
@property(nonatomic, retain) NSString				*parentController;
@property(nonatomic, retain) Entry					*entry;

- (void)showWebPageView;
- (void)checkForMovement;
- (void)reloadpageView;
- (IBAction)backpageView;
- (IBAction)forwardpageView;
- (void)closeView;
- (void)resize;
@end
