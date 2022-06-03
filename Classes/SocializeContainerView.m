//
//  SocializeContainerView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 12/13/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeContainerView.h"
#import "AppMakrUINavigationBarBackground.h"
#import "PointAboutTabBarScrollViewController.h"
#import "AMAudioPlayerViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import <Socialize/Socialize.h>  
#import "GlobalVariables.h"

#define MIN_MODAL_DISMISS_INTERVAL 0.75

float navBarStartPosition;

@interface SocializeContainerView (Internal)
- (void) setupGestureRecognizer:(UIViewController *)viewController;
- (void) toggleStatusView;
- (void) setNavigationDelegates:(NSArray *)viewControllers;
- (void) showStartupInfoView;
- (void) showProfileController;
- (BOOL) socializeEnable;
- (void) trackSwipeUpAction;
@end

@implementation SocializeContainerView


-(void) dealloc {
	[rootViewController release];
	[socializeViewController release];
	[closeButton release];
	
	[super dealloc];
}

-(id) initWithViewController:(UIViewController *)viewController frame:(CGRect)theFrame {
	
	if( (self = [super initWithFrame:theFrame]) ) {
		NSAssert(viewController != nil,@"The view controller being passed into socialize container view is nil ");
		rootViewController = [viewController retain];

		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.autoresizesSubviews = YES;
		self.backgroundColor = [UIColor blackColor];
		self.contentMode = UIViewContentModeRedraw;
		
		//WE CHECK HERE FOR TABBAR CONTROLLER BECAUSE WE HAVE TO IMPLEMENT THIS FOR THE
		//CASE WHEN THERE IS ONLY ONE ROOT VIEW CONTROLLER AND NO TABBAR IS PRESENT.

//[#26189315] disable swipe-up 
        
//		if( [rootViewController isKindOfClass:[UITabBarController class]]) 
//		{
//			UITabBarController *tabBarController = (UITabBarController *)rootViewController;
//			tabBarController.delegate = self;
//            if([self socializeEnable])
//            {
//                UISwipeGestureRecognizer * sgr = [UISwipeGestureRecognizer recognizerWithHandler:
//                                                  ^(UIGestureRecognizer* sender, UIGestureRecognizerState state, CGPoint location)
//                                                  {
//                                                      [self trackSwipeUpAction];
//                                                  }];
//                sgr.direction = UISwipeGestureRecognizerDirectionUp;
//                [tabBarController.tabBar addGestureRecognizer:sgr];
//            }
//			DebugLog(@"tabbar height is : %f", tabBarController.tabBar.frame.size.height);
//			
//            [self setNavigationDelegates:tabBarController.viewControllers];
//			tabBarController.moreNavigationController.delegate = self;
//		}

		rootViewController.view.frame = CGRectMake(0,20,self.frame.size.width, self.frame.size.height-20);
		[self addSubview:rootViewController.view];
		
		//CREATE THE CLOSE BUTTON THAT SITS ON THE TOP OF THE SOCIALIZE VIEW AND DISMISSES IT.
		UIImage * closeImage = [UIImage imageNamed:@"socialize_resources/close_bar.png"];
		closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		closeButton.backgroundColor = [UIColor clearColor];
		[closeButton setImage: closeImage forState:UIControlStateNormal];
		[closeButton addTarget:self action:@selector(socializeSwipeDown) forControlEvents:UIControlEventTouchUpInside];
		
		CGRect cbFrame = CGRectMake(0, self.frame.origin.y + self.frame.size.height - 5, closeImage.size.width, closeImage.size.height +10);
		closeButton.frame = cbFrame;
		
//		NOW WE SHOULD SETUP THE SOCIALIZE VIEW CONTROLLER TO SIT BELOW THE CLOSE BUTTON
		float socializeOriginY = closeButton.frame.size.height + closeButton.frame.origin.y;
		
		CGRect socializeFrame = CGRectMake(0, socializeOriginY-5, self.frame.size.width, self.frame.size.height - closeButton.frame.size.height+10);
		socializeViewController = [[SocializeViewController alloc] initWithNibName:@"SocializeViewController" bundle:nil]; 
		socializeViewController.view.frame = socializeFrame;

		[self addSubview:socializeViewController.view];
		[self setNavigationDelegates:socializeViewController.paTabBarScrollViewController.viewControllers];
		[self addSubview: closeButton];  //Add the button last so that it is on top.
	}
	return self;
}

-(void) trackSwipeUpAction
{
//    Socialize* socialize = [[Socialize alloc]initWithDelegate:nil];
//    if(![socialize isAuthenticatedWithThirdParty] && [socialize thirdPartyAvailable])
//    {
//        [self requestAuthentication];
//    }
//    else
//    {
//        [self showProfileController];
//    }
//    [socialize release];    
}

-(void)showProfileController
{
    UINavigationController* profile = [SocializeProfileViewController currentUserProfileWithDelegate:nil];
    [rootViewController presentModalViewController:profile animated:YES];
}


-(BOOL) socializeEnable
{
    NSDictionary* application = (NSDictionary * )[[GlobalVariables getPlist] objectForKey:@"application"];
    return [[application objectForKey:@"socialize_enabled"] boolValue];      
}

-(void)setNavigationDelegates:(NSArray *)viewControllers {
	for(UIViewController *viewController in viewControllers ) {
		if( [viewController isKindOfClass:[UINavigationController class]] ) {
			UINavigationController *navigationController = (UINavigationController *)viewController;
			navigationController.delegate = self;	
		}
	}	
}

-(void)socializeSwipeUp {
	_isSocializeViewDisplayed = YES;
	navBarStartPosition = 0;
	[socializeViewController viewWillAppear:YES];
	//ANIMATE DOWNSARDS TO VIEW THE SOCIALIZE VIEWS
	[[UIApplication sharedApplication]setStatusBarHidden:YES];
	[UIView beginAnimations:@"SwipingUp" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[socializeViewController.view setNeedsLayout];
	self.bounds = CGRectMake(0, closeButton.frame.origin.y+4, self.frame.size.width, self.frame.size.height);
	[UIView commitAnimations];
}


-(void)socializeSwipeUpToShowSocializeInfo {
	_isSocializeViewDisplayed = YES;
	navBarStartPosition = 0;
	[socializeViewController viewWillAppear:YES];
	//ANIMATE DOWNSARDS TO VIEW THE SOCIALIZE VIEWS
	[[UIApplication sharedApplication]setStatusBarHidden:YES];
	[UIView beginAnimations:@"SwipingUpToShowSocializeInfo" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	[socializeViewController.view setNeedsLayout];
	self.bounds = CGRectMake(0, closeButton.frame.origin.y+4, self.frame.size.width, self.frame.size.height);
	[UIView commitAnimations];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	if ([animationID isEqualToString:@"SwipingUpToShowSocializeInfo"]){
		[self showStartupInfoView];
	}
	else if ([animationID isEqualToString:@"SocializeSwipeDown"]){
		[socializeViewController removeInfoView];
	}
}

-(void)socializeSwipeDown {
	_isSocializeViewDisplayed = NO;
	DebugLog(@"making socialize go down!");
	navBarStartPosition = 20;
	//ANIMATE DOWNSARDS TO VIEW THE SOCIALIZE VIEWS
   	[[UIApplication sharedApplication]setStatusBarHidden:NO];
	[UIView beginAnimations:@"SocializeSwipeDown" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	self.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	[UIView commitAnimations];

	// hide the one time info view displayed at the start of the application
}
- (void)navigationController:(UINavigationController *)localNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
}

- (void)navigationController:(UINavigationController *)localNavigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	//EMTPY PLACE HOLDER
}

-(void)hideSocializeTabBar{
	if (_isSocializeViewDisplayed)
		[socializeViewController hideSocializeTabBar];

}
-(void)showStartupInfoView{
	[closeButton addTarget:self action:@selector(socializeSwipeDown) forControlEvents:UIControlEventTouchUpInside];
	[socializeViewController showStartUpViewWithDelegate:self];
}


-(void)gotoActivityView{
	[socializeViewController selectTheActivityView];
    //	[socializeViewController selectTheProfileView];
	[socializeViewController removeInfoView];
}

-(void)gotoProfileView{
	[socializeViewController selectTheProfileView];
    //	[socializeViewController selectTheProfileView];
	[socializeViewController removeInfoView];
}


-(void)swipeUpToMainView{
	[self socializeSwipeDown];
}

-(void)unHideSocializeTabBar{
	if (_isSocializeViewDisplayed)
		[socializeViewController unHideSocializeTabBar];
}

#pragma mark - SocializeAuthViewControllerDelegate

- (void)executeAfterModalDismissDelay:(void (^)())block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, MIN_MODAL_DISMISS_INTERVAL * NSEC_PER_SEC), 
                   dispatch_get_main_queue(),
                   block);
}

- (void)dismissSelf {
    // In the case that the user just came back from the SocializeAuthViewController, and the 
    // socialize server finishes creating the comment before the modal dismissal animation has played,
    // we need to hack a delay for iOS5 or the second dismissal will not happen
    
    // Double animated dismissal does not work on iOS5 (but works in iOS4)
    // Allow previous modal dismisalls to complete. iOS5 added dismissViewControllerAnimated:completion:, which
    // we could also use for the previous dismissal, but this is a little simpler and lets us ignore version differences.
    [self executeAfterModalDismissDelay:^{
        [rootViewController dismissModalViewControllerAnimated:YES];
    }];
}

-(void) authorizationSkipped
{
    [self executeAfterModalDismissDelay:^{
        [self showProfileController]; 
    }];
}

@end
