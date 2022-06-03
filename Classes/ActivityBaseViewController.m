//
//  ActivityBaseViewController.m
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ActivityBaseViewController.h"
#import "ActivityTableViewDelegate.h"
#import "AppMakrUINavigationBarBackground.h"

@implementation ActivityBaseViewController

@synthesize theService;
@synthesize activitiesArray;


- (void)dealloc 
{
   activityTableViewController.tableView.delegate = nil;
	
   [activityTableViewController release];
   [tableViewDelegate release];
   [theService release];
   [activitiesArray release];
   [activitySpinner release];
	
   [super dealloc];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		activitySpinner = nil;
		tableViewDelegate = [[ActivityTableViewDelegate alloc]init];
		tableViewDelegate.activityController = self;
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
 {
    [super viewDidLoad];
	activitySpinner = nil; 
	activityTableViewController.tableView.delegate = tableViewDelegate;
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar showCustomBackgroundImage];
    
    if (!activitiesArray){
        
        if(!self.theService) {
            AppMakrSocializeService * ss = [[AppMakrSocializeService alloc]init];
            self.theService = ss;
            self.theService.delegate = self;
            [ss release];
        }
        
        if (activitySpinner == nil) 
        {
            activitySpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activitySpinner.hidesWhenStopped = YES;
            activitySpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;	
            [self.view addSubview:activitySpinner];

        }
        activitySpinner.center  = activityTableViewController.tableView.center;
        [activitySpinner startAnimating];
    }
    else{
        if (activitiesArray){
            activityTableViewController.activitiesArray = activitiesArray;
            [activityTableViewController.tableView reloadData];	
        }
    }
}
		
-(void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[activitySpinner stopAnimating];
	[self.theService cancelAllFetchRequests];
	/*
	self.activitiesArray = nil;
	activityTableViewController.activitiesArray = nil;
	self.theService = nil; 
     */

}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	activitySpinner.center = activityTableViewController.tableView.center;
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchActivities:(NSArray *)activities error:(NSError *)error
{
	DebugLog(@"Activity error: %@", [error localizedDescription]);
	NSInteger currentActivityCount = [self.activitiesArray count];
	[activitySpinner stopAnimating];
	if (([activities count] <= 0) && (currentActivityCount <=0)) 
	{
		activityTableViewController.informationView.noActivityImageView.hidden = NO;
		activityTableViewController.informationView.hidden = NO;
	}
	else 
	{
		if ([activities count]>0) 
		{
			self.activitiesArray = activities;
			activityTableViewController.activitiesArray = activities;
            [activityTableViewController.tableView reloadData];	
		}
		
		activityTableViewController.informationView.noActivityImageView.hidden = YES;
		activityTableViewController.informationView.hidden = YES;
	}

	if (error && (currentActivityCount <=0)) 
	{
		
		activityTableViewController.informationView.errorLabel.hidden = NO;
				
	}
	else 
	{
		activityTableViewController.informationView.errorLabel.hidden = YES;
			
	}

		
	
}


@end
