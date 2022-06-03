//
//  WebpageController.h
//  appbuildr
//
//  Created by PointAboutAdmin on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebSliderViewController : UIViewController <UIWebViewDelegate> {
	UIWebView * webpageView;
	NSString * feedURL;
	UIActivityIndicatorView *spinner;
	UIBarButtonItem * backButton;
	UIBarButtonItem * forwardButton;
    BOOL statusBarWasHiden;
}

@property(nonatomic, retain) UIWebView * webpageView;
@property(nonatomic, assign) BOOL statusBarWasHiden;


+ (void) popOut:(NSURLRequest *)request forView:(UIView*)view;

- (void)checkForMovement;
- (void)reloadpageView;
- (IBAction)backpageView;
- (IBAction)forwardpageView;
- (void)closeView;
@end
