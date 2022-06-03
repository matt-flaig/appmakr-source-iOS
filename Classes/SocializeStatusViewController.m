    //
//  SocializeStatusViewController.m
//  appbuildr
//
//  Created by William Johnson on 3/2/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "SocializeStatusViewController.h"
#import "SocializeStatusView.h"
#import "AMAudioPlayerViewController.h"

@interface SocializeStatusViewController ()

-(void) toggleStatusView;

@end


@implementation SocializeStatusViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		isStatusViewHidden = YES;
		audioIsLoaded = NO;
        AMAudioPlayerViewController *audioPlayer = [AMAudioPlayerViewController sharedInstance];
		audioPlayer.delegate = self;
		 
    }
    return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{

	swipeUpView = [[SocializeStatusView alloc] initWithFrame:CGRectZero];
	self.view = swipeUpView;
	[swipeUpView release];
}


-(void) showInView:(UIView *)localView
{
	CGRect swipeFrame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height );
	self.view.frame = swipeFrame;
	[localView addSubview:self.view]; 
}

#pragma mark audio calbacks

-(void)audioCloseButtonPressed:(AMAudioPlayerViewController *)audioPlayer {
	if( !isStatusViewHidden ) {
		[self toggleStatusView];
	}
}

-(void)audioWillLoad:(AMAudioPlayerViewController *)audioPlayer {
	audioIsLoaded = YES;
	if( isStatusViewHidden ) {
		[self toggleStatusView];					
		[self performSelector:@selector(toggleStatusView) withObject:nil afterDelay:5];
	}
}

-(void)audioError:(AMAudioPlayerViewController *)audioPlayer audioError:(NSError *)error {
	audioIsLoaded = NO;
	if( !isStatusViewHidden ) { 
		[self toggleStatusView];
	}
}

-(void) toggleStatusView 
{
	if( isStatusViewHidden && audioIsLoaded ) {	
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		CGRect swipeFrame = CGRectMake(0,0, swipeUpView.frame.size.width, swipeUpView.frame.size.height );
		swipeUpView.frame = swipeFrame;
		[UIView commitAnimations]; 
		isStatusViewHidden = NO;
	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelegate:self];
		CGRect swipeFrame = CGRectMake(0,-swipeUpView.frame.size.height, swipeUpView.frame.size.width, swipeUpView.frame.size.height );
		swipeUpView.frame = swipeFrame;
		[UIView commitAnimations]; 
		isStatusViewHidden = YES;
	}
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

//- (void)viewDidLoad 
//{
//    [super viewDidLoad];
//	
//	AMAudioPlayerViewController *audioPlayer = [AMAudioPlayerViewController sharedInstance];
//	
//	UIScreen* mainScreen = [UIScreen mainScreen];
//	CGRect currentFrame = CGRectMake(0, 0, mainScreen.bounds.size.width,
//									 audioPlayer.view.frame.size.height);
//	
//	self.view.frame = currentFrame;
//}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[super dealloc];
}


@end
