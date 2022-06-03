//
//  appbuildrAppDelegate.h
//  appbuildr
//
//  Created by Isaac Mosquera on 1/8/09.
//  Copyright appmakr 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebpageViewController.h"
#import "FeedTableViewController.h"
#import "SplashViewController.h"
#import "LoginViewController.h"
#import "GlobalVariables.h"
#import "SocializeContainerView.h"
#import "FBConnect.h"
#import "AppMakrSocializeService.h"

#import "Socialize/Socialize.h"

@class appbuildrViewController;
@protocol PlatformTemplate;

@interface appbuildrAppDelegate : NSObject <UIApplicationDelegate,LoginViewControllerDelegate, GlobalVariablesDelegate> {
    id<PlatformTemplate>    appTemplate; 
	IBOutlet UIWindow		*window;
	WebpageViewController   *webpageController;
	SplashViewController    *splashViewController;
	UIActivityIndicatorView *_loadingIndicatorView;
    DataStore               *localDataStore;
}

-(void)continueLaunching;
-(void)showAppExpiredAlertWithMessage:(NSString*)myMessage;
-(void)retainActivityIndicator;
-(void)releaseActivityIndicator;

@property (nonatomic, retain) UIWindow				 *window;
@property (nonatomic, retain) WebpageViewController  *webpageController;


@end


