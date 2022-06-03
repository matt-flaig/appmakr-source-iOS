//
//  SocializeStatusViewController.h
//  appbuildr
//
//  Created by William Johnson on 3/2/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAudioPlayerViewController.h"

@class SocializeStatusView;

@interface SocializeStatusViewController : UIViewController <AMAudioPlayerViewControllerDelegate>
{
    @private
		SocializeStatusView *swipeUpView;
		BOOL isStatusViewHidden;
		BOOL audioIsLoaded;
}


-(void) showInView:(UIView *)localView;


@end
