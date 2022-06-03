//
//  AppMakrProfileViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityBaseViewController.h"
#import "ProfileEditViewController.h"
#import "AppMakrSocializeUser.h"
#import "AuthorizeViewController.h"



@interface AppMakrProfileViewController : ActivityBaseViewController <ProfileEditViewControllerDelegate,UINavigationControllerDelegate, AuthorizeViewDelegate >
{
	
	IBOutlet UILabel		*usernameLabel;
	IBOutlet UILabel		*userDescriptionLabel;
	IBOutlet UILabel		*userLocationLabel;
	
	IBOutlet UIView			*profileStatsView;
	IBOutlet UIImageView	*profileImageView;
	IBOutlet UIImageView	*locationIcon;
	IBOutlet UIActivityIndicatorView *spinner;
	
	ProfileEditViewController *profileEditViewController;
	AppMakrSocializeUser			  *userProfile;
	NSString				  *userId;
  
    // variable needed for authorization
    AppMakrSocializeService           *socializeService;
    AuthorizeViewController    *authorizeViewController;
    
}

@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) AppMakrSocializeUser		  *userProfile;
@property(nonatomic, retain) NSString			  *userId;

-(void)resize;

@end
