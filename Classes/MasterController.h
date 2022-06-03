//
//  MasterController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 4/26/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppMakrUINavigationBarBackground.h"
#import "CustomActivityView.h"
#import "PointAboutViewController.h"
#import "ModuleIndexPath.h"
@class Link;

@interface MasterController : PointAboutViewController 
{
	UIImage					*headerImage;
    UIImage                 *homeMenuButton;
	BOOL					isNavigationBarHidden;
	UIView					*audioView;
	CustomActivityView		*customActivityView;
	MPMoviePlayerController *moviePlayer;
	NSString				*moduleType;
	UITapGestureRecognizer	*navBarTap;
}

@property (nonatomic, retain) UIImage *headerImage;
@property (nonatomic, retain) UIImage *homeMenuButton;
@property (nonatomic,retain) UIView * audioView;
@property (nonatomic, retain) NSString * moduleType;
@property (nonatomic, copy) ModuleIndexPath* modulePath;

-(void)showAlertView:(NSString *)alertTitle description:(NSString*)alertDescription;
-(void)hideNavigationBarView;
-(void)showNavigationBarView;
-(void)toggleNavigationBarView ;
-(void)playVideoAtURL:(NSURL *)movieURL;
-(void)playVideoWithLink:(Link *)videoLink;
-(void)playAudioWithLink:(Link *)audioLink;
-(void)retainActivityIndicatorMiddleOfView;
-(void)releaseActivityIndicatorMiddleOfView;
-(void) OnConfigUpdate: (NSNotification*) notification;
-(UIBarButtonItem*) createBackToMainMenuBtnItem;
-(void) dismiss;
@end
