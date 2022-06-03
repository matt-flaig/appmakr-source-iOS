//
//  ProfileEditViewController.h
//  appbuildr
//
//  Created by William Johnson on 1/10/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProfileEditTableViewCell;
@class ProfileEditValueController;
@protocol ProfileEditViewControllerDelegate;

@interface ProfileEditViewController : UITableViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate>
{

	id<ProfileEditViewControllerDelegate> delegate;
	NSArray						*keysToEdit;
	NSMutableDictionary		   *keyValueDictionary;
	ProfileEditTableViewCell   *profileEditViewCell;
	ProfileEditValueController *editValueViewController;
	UIImage					*profileImage;
	UIImagePickerController *imagePicker;
	NSArray					*cellBackgroundColors;
}

@property (nonatomic, assign) id<ProfileEditViewControllerDelegate> delegate;
@property (nonatomic, assign) IBOutlet ProfileEditTableViewCell * profileEditViewCell;
@property (nonatomic, retain) NSArray * keysToEdit;
@property (nonatomic, retain) NSMutableDictionary * keyValueDictionary;
@property (nonatomic, readonly) UIImage * profileImage;


-(void)setProfileImage:(UIImage *) profileImage;
-(void)updateDidFailWithError:(NSError *)error;

@end


@protocol  ProfileEditViewControllerDelegate
-(void)profileEditViewController:(ProfileEditViewController*)controller didFinishWithError:(NSError*)error;
-(void)profileEditViewControllerDidCancel:(ProfileEditViewController*)controller;
@end