//
//  GADAdViewController.h
//  Google Ads iPhone publisher SDK.
//  Version: 2.0
//
//  Copyright 2009 Google Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol GADAdViewControllerDelegate;

typedef struct {
  NSUInteger width;
  NSUInteger height;
} GADAdSize;

// Supported ad size.
static GADAdSize const kGADAdSize320x50 = { 320, 50 };

// Ad click actions
typedef enum {
  // Launch the advertiser's website in Safari
  GAD_ACTION_LAUNCH_SAFARI,
  // Display the advertiser's website in the app (as a subview of the window)
  GAD_ACTION_DISPLAY_INTERNAL_WEBSITE_VIEW,
  // Pass back a UIViewController for displaying the advertiser's website
  GAD_ACTION_DELEGATE_WEBSITE_VIEW,
} GADAdClickAction;

///////////////////////////////////////////////////////////////////////////////
// View controller for displaying an ad
///////////////////////////////////////////////////////////////////////////////
typedef struct __GADAdViewControllerPrivate GADAdViewControllerPrivate;

@interface GADAdViewController : UIViewController <UIWebViewDelegate> {
 @private
  GADAdViewControllerPrivate *private_;
}

@property(nonatomic, assign) GADAdSize adSize;  // default: kGADAdSize320x50
@property(nonatomic, assign) id<GADAdViewControllerDelegate> delegate;

// Initialize and passes the application delegate
- (id)initWithDelegate:(id<GADAdViewControllerDelegate>)delegate;

// Loads the ad from the Google Ad Server.
- (void)loadGoogleAd:(NSDictionary *)attributes;

// Dismiss the website view
- (void)dismissWebsiteView;

@end

///////////////////////////////////////////////////////////////////////////////
// Delegate for receiving GADAdViewController messages
///////////////////////////////////////////////////////////////////////////////
@protocol GADAdViewControllerDelegate <NSObject>
@optional

// Invoked when the ad load completes.
- (void)adControllerDidFinishLoading:(GADAdViewController *)adController;

// Invoked if the ad load fails
- (void)adController:(GADAdViewController *)adController
     failedWithError:(NSError *)error;

// |adControllerActionModelForAdClick:| will be called when a user taps on an
// ad. The delegate can override the default behavior (opening in Safari).
- (GADAdClickAction)adControllerActionModelForAdClick:
    (GADAdViewController *)adController;

// This method is called by |GADAdViewController| if
// |adControllerActionModelForAdClick| returns
// GAD_ACTION_DELEGATE_WEBSITE_VIEW. The responder is responsible for retaining
// and displaying the websiteViewController's view. This allows you to have
// finer control over how the view is displayed.
- (void)adController:(GADAdViewController *)adController
    delegateWebsiteView:(UIViewController *)websiteViewController;

@end
