//
//  PointAboutMoviePlayerViewController.m
//  MoviePlayer
//
//  Created by William M. Johnson on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PointAboutMoviePlayerViewController.h"
#import "FullscreenEvents.h"

@implementation PointAboutMoviePlayerViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (id)initWithContentURL:(NSURL *)contentURL
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:)
												 name:MPMoviePlayerLoadStateDidChangeNotification
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:nil];
	
	self = [super initWithContentURL:contentURL];
	if (self) 
	{
	
				
	    [[NSBundle mainBundle]loadNibNamed:@"PointAboutMoviePlayerViewController" owner:self options:nil];
	}
	return self;
}

-(IBAction) cancelButtonPressed:(id)sender
{
	
	NSLog(@"I'm stopping the pointabout movie player!");
	[self.moviePlayer stop];
	[self dismissModalViewControllerAnimated:YES];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	statusView.frame = self.view.bounds;
	[self.view addSubview:statusView];	
	
		
}

-(void)playerLoadStateDidChange:(NSNotification *)notification 
{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerLoadStateDidChangeNotification
												  object:self.moviePlayer];
	
	[spinner stopAnimating];
	statusView.hidden = YES;
}

-(void)movieFinishedCallback:(NSNotification*)aNotification
{
	[self dismissModalViewControllerAnimated:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || toInterfaceOrientation == UIInterfaceOrientationPortrait;
}


- (void)dealloc 
{
    [super dealloc];
}


@end
