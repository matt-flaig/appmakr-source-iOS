//
//  NingProfileViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterController.h"
#import "NingDomainService.h"

@interface NingProfileViewController : MasterController<UIActionSheetDelegate, UIImagePickerControllerDelegate,
										UIActionSheetDelegate, UINavigationControllerDelegate,NingDomainServiceDelegate>{

	IBOutlet UIButton *updateStatusButton;
	IBOutlet UIButton *logoutButton;
	IBOutlet UIButton *addBlogPostButton;
	IBOutlet UIButton *uploadPictureButton;
	IBOutlet UIImagePickerController *imagePicker;
	IBOutlet UILabel *statusMessageLabel;
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *memberSinceLabel;										
	IBOutlet UIImageView *profileImageView;
	IBOutlet UIView *statusMessageBackgroundView;

	NingDomainService *ningService;

}
-(IBAction) logoutButtonPressed:(id)sender;
-(IBAction) updateButtonPressed:(id)sender;
-(IBAction) addBlogPostButtonPressed:(id)sender;
-(IBAction) uploadPictureButton:(id)sender;
-(void) pushMessageModal:(NSString *)messageType image:(UIImage *)selectedImage;
@end
