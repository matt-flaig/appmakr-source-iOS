//
//  ActivityViewController.m
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ActivityViewController.h"
#import "appbuildrAppDelegate.h"
#import "AppMakrNativeLocation.h"
#import "UserAnnotation.h"
#import "Activity.h"
#import "MyGeoPoint.h"
#import "stdlib.h"
#import "AppMakrPinView.h"
#import "ActivityBaseViewController.h"

#import "AccessorizedCalloutMapAnnotationView.h"
#import "TCImageView.h"
#import "AppMakrMapCalloutContentView.h"
#import "EntryViewController.h"
#import "UIButton+Socialize.h"

@interface ActivityViewController(private)

@end

@implementation ActivityViewController



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayMap:(BOOL)displayMap {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        containsAMapView = displayMap; 
    }
    return self;
}

-(void) updateLocation:(NSNotification *)notification{
    
    AppMakrNativeLocation *myLocation = [AppMakrNativeLocation sharedInstance];
    
    if (containsAMapView){
        
        if (!myMapView){
            UIButton* mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [mapButton setFrame:CGRectMake(0, 0, 34, 34)];
            [mapButton setBackgroundImage:[UIImage imageNamed:@"/socialize_resources/socialize-button-nearme.png"] forState:UIControlStateNormal];   // default is nil
            [mapButton addTarget:self action:@selector(flipView) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *mapItem = 
                [[[UIBarButtonItem alloc] initWithCustomView:mapButton] autorelease];
            
            self.navigationItem.rightBarButtonItem = mapItem;
            
            myMapView = [[ActivityMapViewController alloc] initWithUserLocation:myLocation.lastKnownLocation.coordinate];
            myMapView.view.frame = self.view.frame; 
            myMapView.view.hidden = YES;
            
            [myMapView viewWillAppear:YES];
            [[self view] addSubview:myMapView.view];
            myMapView.delegate = self;
        }
    }
}

- (void)viewDidLoad {

	[super viewDidLoad];
    _isMapDisplayed = NO;
    
    activityTableViewController.view.frame = self.view.bounds;
	self.title = @"Activity";
    [self.view addSubview:activityTableViewController.view];
    
    if (containsAMapView){
        NSNotificationCenter * notificationCenter  = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(updateLocation:) name:OBSERVER_DID_LOCATION_UPDATE object:nil];
    }
}

-(void)pushMyViewController:(UIViewController*)viewController animated:(BOOL)animated{
    [self.navigationController pushViewController:viewController animated:animated]; 
}

-(void)popMyViewControllerAnimated:(BOOL)animated{
    [self.navigationController popViewControllerAnimated:animated]; 
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.theService fetchActivities];
	
//    appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate unHideSocializeTabBar];
}

- (void)viewWillDisappear:(BOOL)animated{
    
	[super viewWillDisappear:animated];
}

- (void)flipView {
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.50];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	
	// swap the views and transition
	if (_isMapDisplayed) {
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        activityTableViewController.view.hidden = NO;
        myMapView.view.hidden = YES;
	} else {
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        activityTableViewController.view.hidden = YES;
        myMapView.view.hidden = NO;
        
        [myMapView refreshActivies];
	}
	[UIView commitAnimations];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.50];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
	// swap the views and transition
    UIButton* topRightButtonImage = (UIButton*)self.navigationItem.rightBarButtonItem.customView;
	if (_isMapDisplayed) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationItem.rightBarButtonItem.customView cache:YES];

        [topRightButtonImage setBackgroundImage:[UIImage imageNamed:@"/socialize_resources/socialize-button-nearme.png"] forState:UIControlStateNormal];   
        
	} else {
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationItem.rightBarButtonItem.customView cache:YES];

        [topRightButtonImage setBackgroundImage:[UIImage imageNamed:@"/socialize_resources/socialize-button-recent.png"] forState:UIControlStateNormal];   
	}
	[UIView commitAnimations];
    myMapView.mapIsDisplayed = _isMapDisplayed = !_isMapDisplayed;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  //  self.mapView = nil;
    [super viewDidUnload];
     
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
   [super dealloc];
}


-(IBAction)locationOptionsChanged:(id)control
{
	
}

@end
