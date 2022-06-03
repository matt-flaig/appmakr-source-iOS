//
//  NingLoginViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/10/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterController.h"
#import "NingDomainService.h"
#import "NingDomainServiceDelegate.h"
@interface NingLoginViewController : MasterController<NingDomainServiceDelegate, UITextFieldDelegate> {
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *loginButton;
	IBOutlet UIButton *registerButton;
	IBOutlet UITextField *passwordField;
	IBOutlet UITextField *usernameField;
	IBOutlet UIView *activityView;
	NingDomainService *ningService;
}

-(IBAction) cancelButtonPressed:(id)sender;
-(IBAction) loginButtonPressed:(id)sender;
-(IBAction) registerButtonPressed:(id)sender;
@end
