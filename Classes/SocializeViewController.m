//
//  SocializeModalViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeViewController.h"
#import "ActivityTableViewController.h"
#import "PointAboutTabBarScrollViewController.h"
#import "AppMakrProfileViewController.h"
#import "PointAboutNavigationController.h"
#import "ActivityBaseViewController.h"
#import "ActivityViewController.h"
#import "AppMakrUINavigationBarBackground.h"

@implementation SocializeViewController
@synthesize likesTableViewController;
@synthesize paTabBarScrollViewController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
    }
    return self;
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */
- (void)navigationController:(UINavigationController *)localNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	self.view.autoresizesSubviews  = YES;
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

	UIImage * socializeNavBarBackground = [UIImage imageNamed:@"socialize_resources/socialize-navbar-bg.png"];
	
	profileViewController = [[AppMakrProfileViewController alloc] initWithNibName:@"AppMakrProfileViewController" bundle:nil];
	PointAboutNavigationController * profileNavigationController = [[PointAboutNavigationController alloc]initWithRootViewController:profileViewController]; 
    [profileViewController release];	
	
	[profileNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-profile.png"]
										forState:UIControlStateNormal];
	[profileNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-profile-active.png"]
										forState:UIControlStateSelected ];
	[profileNavigationController.navigationBar setCustomBackgroundImage:socializeNavBarBackground];
	
	ActivityViewController * av = [[ActivityViewController alloc]initWithNibName:@"ActivityViewController" bundle:nil displayMap:YES];
	
	PointAboutNavigationController * activityNavigationController = [[PointAboutNavigationController alloc]initWithRootViewController:av]; 
	activityNavigationController.delegate = self;
	[av release];
	[activityNavigationController.tabBarButton setTitle:@"Activity" forState:UIControlStateNormal];
	
	[activityNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-activity.png"]
					  forState:UIControlStateNormal]; 
	[activityNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-activity-active.png"]
					  forState:UIControlStateSelected];
	
	[activityNavigationController.navigationBar setCustomBackgroundImage:socializeNavBarBackground]; 
	
	likesTableViewController = [[LikesTableViewController alloc]
														  initWithNibName:@"LikesTableViewController" bundle:nil];
	
	PointAboutNavigationController * likesNavigationController  = [[PointAboutNavigationController alloc]initWithRootViewController:likesTableViewController]; 
	[likesTableViewController release];
	
	[likesNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-likes.png"]
										   forState:UIControlStateNormal]; 
	[likesNavigationController.tabBarButton setImage:[UIImage imageNamed:@"/socialize_resources/tabbar/socialize-icon-likes-active.png"]
										   forState:UIControlStateSelected];
	
	[likesNavigationController.navigationBar setCustomBackgroundImage:socializeNavBarBackground]; 
	
	
	NSArray* controllers = [NSArray arrayWithObjects:activityNavigationController, likesNavigationController, profileNavigationController,nil];
	
	[activityNavigationController release];
	[likesNavigationController release];
	[profileNavigationController release];
	
	self.paTabBarScrollViewController = [[PointAboutTabBarScrollViewController alloc] 
																initWithViewControllers:controllers 
																displayType:POINTABOUT_TABBAR_DISPLAY_ICON
																displayTop:false];
	
	UIImage* tabbarImage = [UIImage imageNamed:@"/socialize_resources/tabbar/tabbar-socialize.png"];
	UIImageView *tabBarBackgroundImageView = [[UIImageView alloc] initWithImage:tabbarImage];
	tabBarBackgroundImageView.frame = CGRectMake(0,0, self.view.frame.size.width,tabbarImage.size.height);
	tabBarBackgroundImageView.contentMode = UIViewContentModeScaleToFill;
	paTabBarScrollViewController.tabBarBackgroundImageView = tabBarBackgroundImageView;
	paTabBarScrollViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, tabbarImage.size.height);
	paTabBarScrollViewController.view.frame = CGRectMake(0, 0,
											   self.view.frame.size.width, self.view.frame.size.height);
	[paTabBarScrollViewController viewWillAppear:YES];
	[self.view addSubview:paTabBarScrollViewController.view];
	
}

-(void)hideSocializeTabBar{
	[self.paTabBarScrollViewController hideTabBar];
}

-(void)unHideSocializeTabBar{
	[self.paTabBarScrollViewController unHideTabBar];	
}

- (void)resize {

}

-(void)removeInfoView{

	for (UIButton* barButton in paTabBarScrollViewController.tabBarButtons)
		[barButton removeTarget:self action:@selector(removeInfoView) forControlEvents:UIControlEventTouchUpInside];
	
	if (infoViewController){
		[infoViewController.view removeFromSuperview];
		[infoViewController release];
		infoViewController = nil;
	}
}

-(void)selectTheActivityView{
	[paTabBarScrollViewController selectTheActivityView];
}

-(void)selectTheProfileView{
	[paTabBarScrollViewController selectTheProfileView];
}

-(void)showStartUpViewWithDelegate:(id)mydelegate{
	infoViewController = [[SocializeInfoViewController alloc] initWithNibName:@"SocializeInfoViewController" bundle:nil delegate:mydelegate];
	[self.view addSubview:infoViewController.view];
	
	for (UIButton* barButton in paTabBarScrollViewController.tabBarButtons){
		[barButton addTarget:self action:@selector(removeInfoView) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void)viewWillAppear:(BOOL)animated 
{
	[self.paTabBarScrollViewController viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self.paTabBarScrollViewController viewWillDisappear:animated];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.paTabBarScrollViewController = nil;
	[likesTableViewController release];
    [super dealloc];
}


@end
