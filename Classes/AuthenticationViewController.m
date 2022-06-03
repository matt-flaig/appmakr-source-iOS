//
//  AuthenticationViewController.m
//  appbuildr
//
//  Created by William Johnson on 12/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AuthenticationViewController.h"


@implementation AuthenticationViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations.
     return !UIInterfaceOrientationIsLandscape(interfaceOrientation);
 }


-(void) viewWillAppear:(BOOL)animated
{
	CGFloat viewHeight = self.view.frame.size.height;
	CGRect  spinnerFrame = spinner.frame;
	spinner.frame = CGRectMake(spinnerFrame.origin.x, viewHeight - 40, spinnerFrame.size.width, spinnerFrame.size.height);
}
- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
