//
//  SocializeContainerView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 12/13/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeViewController.h"
#import "SocializeStatusView.h"
#import "AMAudioPlayerViewController.h"

@interface SocializeContainerView : UIView<UINavigationControllerDelegate, UITabBarControllerDelegate,AMAudioPlayerViewControllerDelegate> {
	@private
	UIViewController		*rootViewController;
	SocializeViewController *socializeViewController;
	UIButton				*closeButton;
	BOOL					_isSocializeViewDisplayed;
	BOOL					isStatusViewHidden;
	BOOL					audioIsLoaded;
}
-(id) initWithViewController:(UIViewController *)viewController frame:(CGRect)theFrame;
-(void)hideSocializeTabBar;
-(void)unHideSocializeTabBar;
-(void)socializeSwipeUp;
-(void)socializeSwipeDown;
-(void)socializeSwipeUpToShowSocializeInfo;
@end
