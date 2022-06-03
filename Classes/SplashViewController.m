//
//  SplashViewController.m
//  appbuildr
//
//  Created by Brian Schwartz on 12/30/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "SplashViewController.h"
#import "appbuildrAppDelegate.h"


@implementation SplashViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"splashBasic" ofType:@"m4v"];
	theMovie = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL fileURLWithPath:path]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlayBackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:theMovie];
	
	theMovie.scalingMode = MPMovieScalingModeAspectFill;
	
	[theMovie play];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate continueLaunching];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:theMovie];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[theMovie release];
    [super dealloc];
}


@end
