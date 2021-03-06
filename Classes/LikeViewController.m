//
//  LikeViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "LikeViewController.h"
#import "UIView+RoundedCorner.h"

@implementation LikeViewController

@synthesize  mainView;
@synthesize  outerBackground;
@synthesize  innerBackground;
@synthesize  messageLabel;


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
	[self.view setRoundedCornerOnHierarchy:5.0f];
	[super viewWillAppear:animated];
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

-(IBAction)cancelPressed:(id)sender{
	[modalDelegate dismissModalView:self.view];
}

-(IBAction)shareThisTouched:(id)sender{
//	ShareModalViewController *viewController = [[[ShareModalViewController alloc]
//												 initWithNibName:@"ShareModalViewController" bundle:nil] autorelease];
	
//	[modalDelegate dismissModalView:self.view andPushNewModalController:viewController];
}

- (void)dealloc {
    [super dealloc];
}

@end
