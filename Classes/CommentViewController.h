//
//  CommentViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 11/18/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocializeModalViewController.h"
#import "FBConnect.h"
#import "MGTwitterEngine.h"
#import "SA_OAuthTwitterController.h"
#import "AppMakrSocializeService.h"

#define kTwitterOAuthConsumerKey	@"isKX4MLEDtOjAT08cFZMwQ"
#define kTwitterOAuthConsumerSecret	@"sRJda3PwdQBwc93GVMSg6afMqanjrqakenxXc1SOY"

#define BITLY_IS_ENABLED YES

// set this to NO to bypass the url shortening sevice of bit.ly

#define kCompanySocialize @"0"
#define kCompanyFacebook @"1"
#define kCompanyTwitter @"2"

typedef enum socializePostType{
	SocializeCommentOption,
	TwitterShare,
	FacebookShare
}SocializePostType;

@interface CommentViewController : SocializeModalViewController< FBSessionDelegate, FBRequestDelegate, 
		UIAlertViewDelegate, SA_OAuthTwitterControllerDelegate,UITextViewDelegate> {
	
	IBOutlet UITextView *commentVeiw;
	IBOutlet UILabel	*titleLabel;
	IBOutlet UILabel	*twitterCharCountLabel;// renaing the label name
	IBOutlet UILabel	*facebookMessagePreviewLabel;
	IBOutlet UIView		*attachedLinkImageView;
	IBOutlet UIButton   *submitButton;
    IBOutlet UIButton   *cancelButton;
	
	SocializePostType   _postType;
	NSString			*commentText; 
	Entry				*entry;
	BOOL				isAuthDialogCancelled;

/*****Twitter related stuff**/
	NSString			*tmpBitlyURlString;
	NSString			*username;
	NSString			*twitterApiKey;
	NSString			*twitterApiSecret;
    NSDictionary        *twitterErrorsCodeDesciption;
	
	BOOL				isLoggedInToTwitter;
	BOOL				twitterPostSent;
	
	SA_OAuthTwitterEngine	*_engine;
	NSString				*_facebookUsername;

/*****facebook related stuff**/

	NSArray*			_facebookPermissions;
	AppMakrSocializeService	*theService;
    //
    BOOL _isAuthRequest;
}

@property (nonatomic, retain) IBOutlet UIButton   *cancelButton;
@property (nonatomic, retain) IBOutlet UIButton   *submitButton;
@property (nonatomic, retain) IBOutlet UITextView *commentVeiw;
@property (nonatomic, retain) IBOutlet UILabel	 *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel	 *facebookMessagePreviewLabel;
@property (nonatomic, retain) IBOutlet UILabel	 *twitterCharCountLabel;
@property (nonatomic, retain) IBOutlet UIView	 *attachedLinkImageView;


@property (nonatomic, retain) NSString	 *tmpBitlyURlString;
@property (nonatomic, retain) Entry		 *entry;
@property (nonatomic, retain) NSString	 *commentText;
@property (nonatomic, retain) NSString	 *username;

//-(void)setVariablesForTest:(BOOL)value;

-(IBAction)cancelPressed:(id)sender;
-(IBAction)submitCommentTouched:(id)sender;
-(id)initWithNibName:(NSString *)nibNameOrNil 
			  bundle:(NSBundle *)nibBundleOrNil 
			postType:(SocializePostType)postType
			entry   :(Entry*)myentry;

- (void)setVariablesForTest:(BOOL)value;

@end
