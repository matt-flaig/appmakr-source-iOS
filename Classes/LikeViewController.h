//
//  LikeViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 11/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocializeModalViewController.h"
#import "Entry.h"

@interface LikeViewController : SocializeModalViewController {
	IBOutlet UIView		*mainView;
	IBOutlet UIView		*outerBackground;
	IBOutlet UIView		*innerBackground;
	IBOutlet UILabel	*messageLabel;
}

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIView *outerBackground;
@property (nonatomic, retain) UIView *innerBackground;
@property (nonatomic, retain) UIView *messageLabel;

-(IBAction)cancelPressed:(id)sender;
-(IBAction)shareThisTouched:(id)sender;

@end
