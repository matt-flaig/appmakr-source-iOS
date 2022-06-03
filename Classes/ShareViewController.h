//
//  ShareViewController.h
//  HitFix
//
//  Created by PointAbout Dev on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "MGTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "TouchXML.h"
#import "GlobalVariables.h"
#import "URLDownload.h"
#import "RegexKitLite.h"

typedef enum {
	shareServiceTypeTwitter,
	shareServiceTypeFacebook
} shareServiceTypes;




@class SA_OAuthTwitterEngine;
@protocol ShareViewControllerDelegate;

@interface ShareViewController : UIViewController <FBSessionDelegate, FBDialogDelegate, FBRequestDelegate, UIAlertViewDelegate, UITextViewDelegate, SA_OAuthTwitterControllerDelegate> {
	UINavigationBar		*titleBar;
	UIToolbar			*toolBar;
	UIBarButtonItem		*sendButton;
	UIBarButtonItem		*cancelButton;
	UIBarButtonItem		*spaceButton;
	UIBarButtonItem		*loginButton;
	UITextView			*messageView;
	NSString			*linkTitle;
	NSString			*linkUrl;
	
	NSString			*facebookApiKey;
	NSString			*facebookApiSecret;
	
	NSString			*twitterApiKey;
	NSString			*twitterApiSecret;
	
	NSString			*defaultURL;
	UILabel				*staticUpdateLabel;
	UILabel				*messageTitleLabel;
	UILabel				*characterCountLabel;
	UIActivityIndicatorView *spinner;
	shareServiceTypes shareServiceType;
	//used internally
	NSString			*twitterUsername;
	NSString			*twitterPassword;
	BOOL				hiddenStatusBar;
	Facebook			*facebook;
	NSArray*			_permissions;
	
	MGTwitterEngine		*twitterEngine;
	BOOL				isLoggedInToTwitter;
	BOOL				twitterPostSent;
	
	NSString			*description;
	NSString			*thumbnailURL;
	
	SA_OAuthTwitterEngine *_engine;
	
	id<ShareViewControllerDelegate> delegate;
}

-(id)initWithServiceType:(shareServiceTypes)type title:(NSString *)title url:(NSString *)url;
-(void)finishSetup:(NSString *)url;
-(void)shortenUrl:(NSString *)inputUrl;
-(void)showLogin:(NSString *)tweetString;

@property (nonatomic, retain) UINavigationBar *titleBar;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UIBarButtonItem *sendButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *spaceButton;
@property (nonatomic, retain) UIBarButtonItem *loginButton;
@property (nonatomic, retain) UITextView *messageView;
@property (nonatomic, retain) NSString *linkTitle;
@property (nonatomic, retain) NSString *linkUrl;
@property (nonatomic, retain) UILabel *staticUpdateLabel;
@property (nonatomic, retain) UILabel *messageTitleLabel;
@property (nonatomic, retain) UILabel *characterCountLabel;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *thumbnailURL;
@property (nonatomic, retain) NSString * defaultURL;

@property (nonatomic, assign) id<ShareViewControllerDelegate> delegate;

@end

@protocol  ShareViewControllerDelegate
- (void)shareViewControllerDelegate:(ShareViewController*)controller didFinishWithText:(NSString*)text type:(shareServiceTypes)type error:(NSError*)error;
@end

