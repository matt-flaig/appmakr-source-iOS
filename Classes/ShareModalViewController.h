//
//  ShareModalViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CommentViewController.h"
#import "SocializeModalViewController.h"
#import "FBConnect.h"
#import "MGTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "TouchXML.h"
#import "GlobalVariables.h"
#import "AppMakrURLDownload.h"
#import "RegexKitLite.h"

@interface ShareModalViewController : SocializeModalViewController<SocializeModalViewCallbackDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate, 
UIAlertViewDelegate, SA_OAuthTwitterControllerDelegate, MFMailComposeViewControllerDelegate> {
	Entry						 *entry;
	SocializeModalViewController *_modalViewController;

	NSString			*twitterApiKey;
	NSString			*twitterApiSecret;
	
	Facebook			*facebook;
	NSArray*			_permissions;
	
	BOOL				isLoggedInToTwitter;
	BOOL				twitterPostSent;
	
	NSString			*description;
	NSString			*thumbnailURL;
	
	SA_OAuthTwitterEngine	*_engine;
	SocializePostType	_postType;
	NSString			*_facebookUsername;
	UIView				*_emailView;
	MFMailComposeViewController *mailController;
}

@property (nonatomic, retain) Entry		 *entry;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry*)myentry;
-(IBAction)cancelPressed:(id)sender;
-(IBAction)shareThisTouched:(id)sender;
-(IBAction)emailThisTouched:(id)sender;
-(IBAction)shareOnFacebookTouched:(id)sender;
-(IBAction)shareOnTwitterTouched:(id)sender;

-(void)showLogin:(NSString *)tweetString;

@property (nonatomic, retain) NSString *linkTitle;
@property (nonatomic, retain) NSString *linkUrl;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *thumbnailURL;

@end
