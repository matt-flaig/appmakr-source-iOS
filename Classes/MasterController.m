//
//  MasterController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 4/26/10.
//  Copyright 2010 pointabout. All rights reserved.
//


#import "MasterController.h"
#import "PointAboutMoviePlayerViewController.h"
#import "Link.h"
#import "SocializeStatusViewController.h"
#import "SocializeStatusView.h"
#import "GlobalVariables.h"


@interface MasterController ()
- (void)setupStatusView;
- (void)setupGestureRecognizerInView:(UIView *)localView;
@end


@implementation MasterController

@synthesize headerImage;
@synthesize audioView;
@synthesize moduleType;
@synthesize modulePath = _modulePath;
@synthesize homeMenuButton;

static SocializeStatusViewController * statusViewController = nil;

+(void)initialize
{
	if (self == [MasterController class]) 
	{
		if (statusViewController == nil) 
		{
			statusViewController = [[SocializeStatusViewController alloc] initWithNibName:nil bundle:nil];
		}
	}
}


-(void) dealloc
{
    [GlobalVariables removeObserver:self];
	[headerImage release];
    [homeMenuButton release];
	[audioView release];
	[customActivityView release];
	[moviePlayer stop];
	[moviePlayer release];
    self.modulePath = nil;
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	if( (self = [super initWithNibName:nibName bundle:nibBundle])) 
	{
		isNavigationBarHidden = NO;
		moviePlayer = nil;
		navBarTap  = nil;
        [GlobalVariables addObserver:self selector:@selector(OnConfigUpdate:)];
	}
	
	return self;
	
}
-(void) hideNavigationBarView {
	if (!isNavigationBarHidden ) {//makes sure this function isn't called when it's already hidden
		isNavigationBarHidden = YES;
		[UIView beginAnimations:@"hideNavigationBarView" context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationBeginsFromCurrentState:YES];
		float yCoordinate = self.navigationController.navigationBar.frame.origin.y -self.navigationController.navigationBar.bounds.size.height;
		[self.navigationController.navigationBar setFrame:CGRectMake(0, yCoordinate, 
																	 self.navigationController.navigationBar.bounds.size.width, 
																	 self.navigationController.navigationBar.bounds.size.height)];
		[UIView commitAnimations];
	}
}

-(void)showNavigationBarView {

	if (isNavigationBarHidden ) { //makes sure this function isn't called when its already showing
		isNavigationBarHidden = NO;
		[UIView beginAnimations:@"showNavigationBarView" context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationBeginsFromCurrentState:YES];
		float yCoordinate = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.bounds.size.height;
		[self.navigationController.navigationBar setFrame:CGRectMake(0,yCoordinate, 
																	 self.navigationController.navigationBar.bounds.size.width, 
																	 self.navigationController.navigationBar.bounds.size.height)];
		[UIView commitAnimations];
		
	}
}



- (void)setupGestureRecognizerInView:(UIView *)localView
{
	navBarTap = [[UITapGestureRecognizer alloc]initWithTarget:statusViewController action:@selector(toggleStatusView)];
	navBarTap.numberOfTapsRequired = 1;
	navBarTap.cancelsTouchesInView = NO;
	[localView addGestureRecognizer:navBarTap];
	[navBarTap release];
}

- (void)setupStatusView
{
	UINavigationBar * navBar = self.navigationController.navigationBar;
	if (!navBarTap && navBar) 
	{
		[self setupGestureRecognizerInView:navBar];
		
	}
	[statusViewController showInView:self.view];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[self setupStatusView];
}

//																			  
//- (void)applicationDidBecomActive:(NSNotification*)aNotification
//{
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:UIApplicationDidBecomeActiveNotification
//												  object:nil];
//	[self viewWillAppear:NO];
//}
//
//-(void)viewWillDisappear:(BOOL)animated
//{
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:UIApplicationDidBecomeActiveNotification
//												  object:nil];
//}
//
-(void)viewDidLoad
{
	[super viewDidLoad];
	moviePlayer = nil;
	customActivityView = [[CustomActivityView alloc] initWithTitle:@"Loading Audio..."];
	customActivityView.hidden = YES;
	[self.view addSubview:customActivityView];
}

- (void) playVideoAtURL:(NSURL *)movieURL
{
	[moviePlayer stop];
	[moviePlayer release];
	moviePlayer = nil;
	//WMJ 8-11-2010: The following check "NSClassFromString(@"MPMoviePlayerViewController")" doesn't work.  Although the documentation states that the
	//MPMoviePlayerViewController is "Available in iPhone OS 3.2 and later.", the class is NOT nil on devices less than 3.2. There for it thinks
	//that this class exists on those devices but an exception is thrown if you attempt to use the class."PointAboutMoviePlayerViewController"
	//inherits from this class.
	
	//Class mpMoviePlayerVC =	(NSClassFromString(@"MPMoviePlayerViewController"));
	//if (mpMoviePlayerVC!=nil) 
	
	//WMJ 8-11-2010: Using the @selector(view) as the way to determine if the MPMoviePlayerViewController should be used. The iOS documentation shows that
	//the view property of the MPMoviePlayerController was introduced at the same time as the MPMoviePlayerViewController; hence, I use the view
	//property to determine whether to use the VC.
	
	BOOL useMovieViewController = [MPMoviePlayerController instancesRespondToSelector:@selector(view)];
	if (useMovieViewController) 
	{
		PointAboutMoviePlayerViewController  * moviePlayerVC = [[PointAboutMoviePlayerViewController alloc]initWithContentURL:movieURL];
		if (self.pointAboutTabBarScrollViewController) {
			[self.pointAboutTabBarScrollViewController presentModalViewController:moviePlayerVC animated:YES];
		}
		else {
			[self presentModalViewController:moviePlayerVC animated:YES];
		}
		[moviePlayerVC release];
	}
	else 
	{
	    
		moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:moviePlayer];
		
		[moviePlayer play];		
	}
}

- (void) playVideoWithLink:(Link *)videoLink
{
	NSURL * movieURL = [NSURL URLWithString:videoLink.href];
	[self playVideoAtURL:movieURL];
  
}

-(void)showAlertView:(NSString *)alertTitle description:(NSString*)alertDescription {

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
													message:alertDescription
												   delegate:nil //TODO:: check if nil correct in this case
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) playAudioWithLink:(Link *)audioLink
{
	NSURL * audioURL = [NSURL URLWithString:audioLink.href];
	
	
	[moviePlayer stop];
	[moviePlayer release];
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:audioURL];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:moviePlayer];
	[moviePlayer.view removeFromSuperview];
		
	CGRect movieFrame = audioView.bounds;
	moviePlayer.view.frame = movieFrame; 
	moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	audioView.hidden = NO;
	[audioView addSubview: moviePlayer.view];
	[audioView bringSubviewToFront:moviePlayer.view];
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:)
													 name:MPMoviePlayerLoadStateDidChangeNotification
												   object:nil];
		
	

	customActivityView.frame = CGRectMake(0, 0, 150, 150);
	customActivityView.center = self.view.center;
	customActivityView.hidden = NO;
	
	[moviePlayer play];	
}

//Needed for backwards compatibility with devices < iPhone OS 3.2
//the next methods have been removed because we no longer support < 4.0
/*
-(void)playerContentPreloadDidFinish:(NSNotification *)notification 
{
	customActivityView.hidden = YES;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerContentPreloadDidFinishNotification
												  object:nil];
}

-(void)playerLoadStateDidChange:(NSNotification *)notification {
	
	customActivityView.hidden = YES;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerLoadStateDidChangeNotification
												  object:nil];
}
*/

// When the movie is done, release the controller.
-(void)movieFinishedCallback:(NSNotification*)aNotification{
	
	if ([moviePlayer respondsToSelector:@selector(view)]) 
	{
		[moviePlayer.view removeFromSuperview];
		audioView.hidden = YES;
    }
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayer];
}

-(void) toggleNavigationBarView {
	if (isNavigationBarHidden ) {
		[self showNavigationBarView];
	} else {
		[self hideNavigationBarView];
	}
}

- (void)retainActivityIndicatorMiddleOfView {
}

- (void)releaseActivityIndicatorMiddleOfView {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

-(void) OnConfigUpdate: (NSNotification*) notification
{
}

-(void) dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

-(UIBarButtonItem*) createBackToMainMenuBtnItem
{
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeBtn setBackgroundImage:self.homeMenuButton forState:UIControlStateNormal];
    [homeBtn setFrame:CGRectMake(0, 0, 41, 33)];
    [homeBtn addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
    
    UIView* container = [[[UIView alloc] initWithFrame:homeBtn.frame]autorelease];
    [container addSubview:homeBtn];
    return [[[UIBarButtonItem alloc] initWithCustomView:container] autorelease];
}
@end