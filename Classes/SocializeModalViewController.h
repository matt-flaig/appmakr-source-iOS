
//
//  SocializeModalViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocializeModalViewCallbackDelegate.h"
#import "MasterController.h"

@interface SocializeModalViewController : MasterController {

	IBOutlet UIView		*alertView;
	IBOutlet UIView		*backgroundView;
	id<SocializeModalViewCallbackDelegate>  modalDelegate;
}

@property (nonatomic, assign) id<SocializeModalViewCallbackDelegate> modalDelegate;
@property (nonatomic, retain) UIView* alertView;
@property (nonatomic, retain) UIView* backgroundView;

- (void)fadeInView;
- (void)fadeOutView;
-(void)show;

@end
