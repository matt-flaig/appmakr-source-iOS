    //
//  AppMakrProfileViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrProfileViewController.h"
#import "appbuildrAppDelegate.h"
#import "Activity.h"
#import "ProfileEditViewController.h"
#import "AppMakrSocializeUser.h"
#import "AppMakrUINavigationBarBackground.h"
#import "SocializeInfoViewController.h"
#import "UIButton+Socialize.h"

@implementation AppMakrProfileViewController
@synthesize profileImageView;
@synthesize userProfile;
@synthesize userId;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		profileEditViewController = [[ProfileEditViewController alloc]initWithStyle:UITableViewStyleGrouped ]; 
		profileEditViewController.delegate = self;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated 
{   
    if (socializeService){
        if ([socializeService userIsAuthenticatedWithProfileInfo] && authorizeViewController){
            [self authorizationCompleted:YES];
        }
    }

	[super viewWillAppear:animated];
	[self resize];
	activitySpinner.center  = activityTableViewController.tableView.center;
	if (self.profileImageView.image == nil) 
	{
		spinner.hidesWhenStopped = YES;
		[spinner startAnimating];
	}
	
	[self.theService fetchProfileForUser:self.userId];
	
	if (self.userId) 
	{
		[self.theService fetchActivitiesForUser:self.userId];
	}
	else 
	{
		[self.theService fetchActivitiesForCurrentUser];
	}

	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.title = @"Authenticate";
	
	//appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	
	if (self.userId) 
	{
		//[appDelegate hideSocializeTabBar];
	}
	else
	{
		//[appDelegate unHideSocializeTabBar];	
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated 
{
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view addSubview:activityTableViewController.view];
    
    self.title = @"Profile";
        
    UIButton * editButton = [UIButton blueSocializeNavBarButtonWithTitle:@"Edit"];
    [editButton addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
	
    if (!self.userId || ([self.userId length] <=0)) 
	{
		UIBarButtonItem  * rightItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
		self.navigationItem.rightBarButtonItem = rightItem;
		rightItem.enabled = NO;
		
		[rightItem release];
	}
	
    UIButton * cancelButton = [UIButton redSocializeNavBarButtonWithTitle:@"Cancel"];
    [cancelButton addTarget:self action:@selector(editVCCancel:) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem * editLeftItem = [[UIBarButtonItem alloc]initWithCustomView:cancelButton];
	profileEditViewController.navigationItem.leftBarButtonItem = editLeftItem;	
	[editLeftItem release];
	
	
    UIButton * saveButton = [UIButton blueSocializeNavBarButtonWithTitle:@"Save"];
	[saveButton addTarget:self action:@selector(editVCSave:) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem  * editRightItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
	profileEditViewController.navigationItem.rightBarButtonItem = editRightItem;	
	[editRightItem release];
    
    socializeService = [[AppMakrSocializeService alloc] init];
    if (socializeService){
        if (![socializeService userIsAuthenticatedWithProfileInfo]){
            self.navigationItem.title = @"Authenticate";
            authorizeViewController = [[AuthorizeViewController alloc] initWithNibName:@"AuthorizeViewController" bundle:nil delegate:self];
            [self.view addSubview:authorizeViewController.view];
            self.navigationItem.rightBarButtonItem.customView.hidden = YES;
        }
    }
}

#pragma mark authorize delegate
-(void)authorizationCompleted:(BOOL)success{
    if (success){
        if (authorizeViewController){
            [authorizeViewController.view removeFromSuperview];
            [authorizeViewController release];
            authorizeViewController = nil;
        }
        self.navigationItem.title = @"Profile";
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    }
}
#pragma -


-(NSMutableDictionary *) valueDictionary
{
	NSMutableDictionary * dictionary = [[[NSMutableDictionary alloc]initWithCapacity:5]autorelease];
	
	if (self.userProfile.firstName != nil) 
	{
	    [dictionary setObject:self.userProfile.firstName forKey:@"first name"];
	}
	
	if (self.userProfile.lastName != nil) 
	{
		[dictionary setObject:self.userProfile.lastName forKey:@"last name"];
	}
	
	if (self.userProfile.userDescription != nil) 
	{
		[dictionary setObject:self.userProfile.userDescription forKey:@"bio"];
	}
	
	return dictionary;
}

-(void)showEditController
{
	NSMutableDictionary * dictionary = [self valueDictionary];
	
	NSArray * keyArray = [NSArray arrayWithObjects:@"first name", @"last name", @"bio", nil];
	
	profileEditViewController.keyValueDictionary = dictionary;
	profileEditViewController.keysToEdit = keyArray;
	
	profileEditViewController.navigationItem.rightBarButtonItem.enabled = NO;
	
	
	UIImage * socializeNavBarBackground = [UIImage imageNamed:@"socialize_resources/socialize-navbar-bg.png"];
	UINavigationController * navController = [[UINavigationController alloc] 
											  initWithRootViewController:profileEditViewController];
	
	[navController.navigationBar setCustomBackgroundImage:socializeNavBarBackground];
	navController.delegate = self;
	navController.wantsFullScreenLayout = YES;
	
	CGRect windowFrame = self.view.window.frame;
	CGRect navFrame = CGRectMake(0,windowFrame.size.height, windowFrame.size.width, windowFrame.size.height);
	navController.view.frame = navFrame;
	navController.navigationBar.tintColor = [UIColor blackColor];
	
	[self.view.window addSubview:navController.view];
	
	
	CGRect newNavFrame = CGRectMake(0, 0, navFrame.size.width, navFrame.size.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(prepare)];
	[UIView setAnimationDuration:0.4];
	navController.view.frame = newNavFrame;
	[UIView commitAnimations];
}

-(void)hideEditController
{
	CGRect windowFrame = self.view.window.frame;
	CGRect navFrame = CGRectMake(0,windowFrame.size.height, windowFrame.size.width, windowFrame.size.height);

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(destroy)];
	[UIView setAnimationDuration:0.4];
	profileEditViewController.navigationController.view.frame = navFrame;
	[UIView commitAnimations];
}

- (void)navigationController:(UINavigationController *)localNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)editVCSave:(id)button
{
	profileEditViewController.navigationItem.rightBarButtonItem.enabled = NO;

	UIImage* newProfileImage = profileEditViewController.profileImage;
	if (newProfileImage)
	{
		self.profileImageView.image = newProfileImage;
	}
	else 
	{
		self.profileImageView.image = [UIImage imageNamed:@"socialize_resources/socialize-profileimage-large-default.png"];
	}

	NSString* firstName = [profileEditViewController.keyValueDictionary valueForKey:@"first name"];
	NSString* lastName = [profileEditViewController.keyValueDictionary valueForKey:@"last name"];
	NSString* description = [profileEditViewController.keyValueDictionary valueForKey:@"bio"];
	[self.theService postToProfileFirstName:firstName
								   lastName:lastName 
								description:description 
									  image:newProfileImage];
	
}

-(void)editVCCancel:(id)button
{
	[self hideEditController];
}

-(void)prepare
{
//	[profileEditViewController resetData];
//	profileEditViewController.firstName.text = self.userProfile.firstName;
//	profileEditViewController.lastName.text = self.userProfile.lastName;
//	profileEditViewController.description.text = self.userProfile.description;
//	profileEditViewController.profileImageView.image = self.profileImageView.image;
//	[profileEditViewController.firstName becomeFirstResponder];	
}


-(void)destroy
{
	[profileEditViewController.navigationController.view removeFromSuperview];
	[profileEditViewController.navigationController.view release];
	[self viewWillAppear:NO];
}

-(void)edit:(id)button
{
	//[profileEditViewController resetData];
	[self showEditController];
	
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
-(void)resize {
	CGRect activityFrame = self.view.frame;
	activityTableViewController.view.frame = CGRectMake(0,160, activityFrame.size.width, activityFrame.size.height-160);
}

-(void)profileEditViewController:(ProfileEditViewController*)controller didFinishWithError:(NSError*)error
{
	//UIImage * newProfileImage = controller.profileImageView.image;
	//if (newProfileImage)
	//	{
	//	//	self.profileImageView.image = controller.profileImageView.image;
	//		
	//	}
	
	
	if (error == nil) 
	{
	}
}

-(void)profileEditViewControllerDidCancel:(ProfileEditViewController*)controller;
{
	[self hideEditController];
}


-(void) socializeService:(AppMakrSocializeService *)socializeService didPostToProfileWithError:(NSError *)error;
{
	profileEditViewController.navigationItem.rightBarButtonItem.enabled = YES;

	if (error == nil) 
	{
		[self hideEditController];
	}
	else 
	{
		[profileEditViewController updateDidFailWithError:error];
	}

}
-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchProfile:(AppMakrSocializeUser *)user error:(NSError *)error
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	
	self.userProfile = user;	
	usernameLabel.text = self.userProfile.username;
	userDescriptionLabel.text = self.userProfile.userDescription;
	
	if ([user.largeImageURL length] > 0) 			
	{   
		[[AppMakrURLDownload alloc] initWithURL:user.largeImageURL sender:self 
										selector:@selector(updateProfileImage:urldownload:tag:) 
									 tag:nil];
	}
	else 
	{
		[spinner stopAnimating];
		self.profileImageView.hidden = NO;
		self.profileImageView.image = [UIImage imageNamed:@"socialize_resources/socialize-profileimage-large-default.png"];
	}
	
}


- (void) updateProfileImage:(NSData *)data urldownload:(AppMakrURLDownload *)urldownload tag:(NSObject *)tag 
{
	[spinner stopAnimating];
	self.profileImageView.hidden = NO;
	if (data!= nil) 
	{
		UIImage *profileImage = [UIImage imageWithData:data];
		self.profileImageView.image = profileImage;
	}
	else
	{
		self.profileImageView.image = [UIImage imageNamed:@"socialize_resources/socialize-profileimage-large-default.png"];	
	}
	
	[profileEditViewController setProfileImage:self.profileImageView.image];

	
	[urldownload release];
}


- (void)dealloc
{
	[userProfile release];
	[profileEditViewController release];
    [super dealloc];
}

@end
