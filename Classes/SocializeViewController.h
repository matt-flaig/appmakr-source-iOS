//
//  SocializeModalViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikesTableViewController.h"
#import "AppMakrProfileViewController.h"
#import "SocializeInfoViewController.h"

@interface SocializeViewController : UIViewController <UINavigationControllerDelegate> 
{
	LikesTableViewController			 *likesTableViewController;
	PointAboutTabBarScrollViewController *paTabBarScrollViewController;
	AppMakrProfileViewController				 *profileViewController;
	SocializeInfoViewController			 *infoViewController;	
}

@property(nonatomic, retain) PointAboutTabBarScrollViewController *paTabBarScrollViewController;
@property(nonatomic, retain) LikesTableViewController			  *likesTableViewController;

-(void)resize;
-(void)hideSocializeTabBar;
-(void)unHideSocializeTabBar;
-(void)showStartUpViewWithDelegate:(id)mydelegate;
-(void)selectTheActivityView;
-(void)selectTheProfileView;
-(void)removeInfoView;
@end