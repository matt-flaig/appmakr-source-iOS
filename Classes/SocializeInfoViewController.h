//
//  SocializeInfoViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 3/2/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SocializeInfoViewDelegate 
-(void)gotoActivityView;
-(void)gotoProfileView;
-(void)swipeUpToMainView;
@end

@interface SocializeInfoViewController : UIViewController {
	IBOutlet UIImageView		  *splashImage;
	IBOutlet UIButton			  *gotoActivityButton;
	IBOutlet UIButton			  *gotoMainViewButton;
	IBOutlet UIToolbar			  *topToolBar;
	id<SocializeInfoViewDelegate> delegate;
}

@property(retain, nonatomic) IBOutlet UIToolbar  *topToolBar;
@property(retain, nonatomic) IBOutlet UIImageView	 *splashImage;
@property(retain, nonatomic) IBOutlet UIButton	 *gotoActivityButton;
@property(retain, nonatomic) IBOutlet UIButton	 *gotoMainViewButton;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
			 delegate:(id<SocializeInfoViewDelegate>)mydelegate;
-(IBAction)gotoActivityPressed:(id)sender;
-(IBAction)gotoMainViewPressed:(id)sender;


@end
