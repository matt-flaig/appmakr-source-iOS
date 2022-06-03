//
//  SocializeModalViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeModalViewController.h"
#import "UIView+RoundedCorner.h"
#import "appbuildrAppDelegate.h"
#import "UIView-AlertAnimations.h"

@implementation SocializeModalViewController

@synthesize  modalDelegate;
@synthesize  alertView;
@synthesize  backgroundView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)viewWillAppear:(BOOL)animated{
	//	self.view.alpha	= 0.0f;
	//	[self.view setRoundedCornerOnHierarchy:5.0f];
}

- (void)fadeInView{
	appbuildrAppDelegate* appdelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	
	self.view.alpha = 0.0f;
	[appdelegate.window addSubview:self.view];
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];
	
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
}

-(void)show{

    // We need to add it to the window, which we can get from the delegate
	self.view.alpha = 1.0f;
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self.view];
    
    // Make sure the alert covers the whole window
    self.view.frame = CGRectMake( window.frame.origin.x, window.frame.origin.y + 20, self.view.frame.size.width, self.view.frame.size.height);
    // self.view.frame.origin = CGPointMake( window.frame.origin.x, window.frame.origin.y + 20);
    
    // "Pop in" animation for alert
    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation for background
    [backgroundView doFadeInAnimation];
}

- (void)fadeOutView{
	self.view.alpha = 1.0f;
	[UIView beginAnimations:@"fadeInSecondView" context:NULL];
	[UIView setAnimationDuration:0.5];

	self.view.alpha = 0.0f;
	[UIView commitAnimations];
	[self.view removeFromSuperview];
}

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


- (void)dealloc {
    [super dealloc];
}


@end