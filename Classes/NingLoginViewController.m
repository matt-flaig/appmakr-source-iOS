//
//  NingLoginViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/10/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "NingLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NingProfileViewController.h"

@implementation NingLoginViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		DebugLog(@"initializing the ning login view");
		ningService = nil;
		//ningService = [[NingDomainService alloc] init];
//		ningService.delegate = self;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	CGRect centerframe = CGRectMake(self.view.center.x - (activityView.frame.size.width/2), self.view.center.y - (activityView.frame.size.height/2) , 
									activityView.frame.size.width, activityView.frame.size.height);
	activityView.frame = centerframe;
	
	[[activityView layer] setCornerRadius:12];
	[[activityView layer] setMasksToBounds:YES];
	activityView.hidden = YES;
	[self.view addSubview:activityView];
	
	
	usernameField.delegate = self;
	passwordField.delegate = self;
	
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:YES];
	
	if (ningService!=nil) 
	{
		[ningService release];
		ningService = nil;
	}
	ningService = [[NingDomainService alloc] init];
	ningService.delegate = self;

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
-(IBAction) loginButtonPressed:(id)sender {
	DebugLog(@"login button pressed");
	DebugLog(@"passing uname: %@, %@", usernameField.text, passwordField.text);
	[ningService loginWithUsername: usernameField.text password: passwordField.text];
}

-(void)serviceCallBack:(NSDictionary *)responseDictionary 
{

	if (ningService.userIsLoggedin) 
	{
		DebugLog(@"callback from login");
		[self dismissModalViewControllerAnimated:YES];
	} else {
		DebugLog(@"login not okay");
		[self showAlertView:@"Invalid Login" description:@"Could not login into this network at this time."];
	}	
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[passwordField resignFirstResponder];
	[usernameField resignFirstResponder];
}

-(IBAction) cancelButtonPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	
}

-(IBAction) registerButtonPressed:(id)sender 
{
	NSURL *url = [NSURL URLWithString:ningService.registrationUrlString];
	[[UIApplication sharedApplication] openURL:url];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self loginButtonPressed:nil];
	[textField resignFirstResponder];
	return YES;
}

- (void)dealloc 
{   [ningService release];
    [super dealloc];
}


@end
