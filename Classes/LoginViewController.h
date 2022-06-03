//
//  LoginViewController.h
//  appbuildr
//
//  Created by William M. Johnson on 7/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SendingMessageView.h"

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
	
	UITextField * usernameField;
	UITextField * passwordField;
	UIAlertView * loginFailedAlertView;
	SendingMessageView * loginInProgressView;
	
	NSString * loginURL;
	id<LoginViewControllerDelegate> delegate;

}

@property (nonatomic,copy) NSString * loginURL;
@property (nonatomic,assign) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>
-(void)loginViewController:(LoginViewController *)controller didAuthenticate:(BOOL)didAuthenticate;
@end

