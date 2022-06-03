//
//  NingProfileViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "NingProfileViewController.h"
#import "NingLoginViewController.h"
#import "NingMessageViewController.h"
#import "AppMakrURLDownload.h"
#import <QuartzCore/QuartzCore.h>
#define MESSAGE_TYPE_BLOG @"add_blog"
#define MESSAGE_TYPE_PICTURE @"add_picture"
#define MESSAGE_TYPE_STATUS @"update_status"
@implementation NingProfileViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
-(void)disable
{
   
	statusMessageLabel.text =@"";	
	updateStatusButton.enabled = NO;
	addBlogPostButton.enabled = NO;
	uploadPictureButton.enabled = NO;
	
	usernameLabel.text = @"";
	memberSinceLabel.text = @"";										
	profileImageView.image = nil;
}

-(void)enable
{
	
	updateStatusButton.enabled = YES;
	addBlogPostButton.enabled = YES;
	uploadPictureButton.enabled = YES;
	
}

-(void)showLoginController
{
	NingLoginViewController *loginViewController = [[NingLoginViewController alloc] init];
	// [self.navigationController setViewControllers:[NSArray arrayWithObject:loginViewController] animated:YES];
	[self presentModalViewController:loginViewController animated:YES];
	[loginViewController release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//ningService = [[NingDomainService alloc] init];
	//ningService.delegate = self;
	imagePicker.delegate = self;
    statusMessageLabel.text = @"";
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	DebugLog(@"view will appear for ning controller");
	
	if (ningService!=nil) 
	{
		[ningService release];
		ningService = nil;
	}
	ningService = [[NingDomainService alloc] init];
	ningService.delegate = self;
	
	[[statusMessageBackgroundView layer] setCornerRadius:12];
	[[statusMessageBackgroundView layer] setMasksToBounds:YES];
	
	if(!ningService.userIsLoggedin)
    {
		[logoutButton setTitle:@"Login" forState:UIControlStateNormal];
		[self disable];
	}
	else 
	{
		[logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
		[self enable];
		
		[ningService getUserInformation];
		
	}	
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
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

-(IBAction) uploadPictureButton:(id)sender 
{
	UIActionSheet *uploadPicActionSheet = nil;
	
	if( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] ) 
	{
		uploadPicActionSheet =[[UIActionSheet alloc] initWithTitle:nil
									delegate:self 
						   cancelButtonTitle:@"Cancel"
					  destructiveButtonTitle:nil
						   otherButtonTitles:@"Choose From Album",@"Take Picture", nil];
		
		
	}
	else 
	{
		uploadPicActionSheet =[[UIActionSheet alloc] initWithTitle:nil
									delegate:self 
						   cancelButtonTitle:@"Cancel"
					  destructiveButtonTitle:nil
						   otherButtonTitles:@"Choose From Album",nil];	
	}


    [uploadPicActionSheet showInView:self.tabBarController.view];
    [uploadPicActionSheet release];
}



-(IBAction) logoutButtonPressed:(id)sender
{
	
	if(ningService.userIsLoggedin) //User wants to logout
    {
		[ningService logout];
		[logoutButton setTitle:@"Login" forState:UIControlStateNormal]; 
		[self disable];
		
	}
	else //user wants to login
	{
		[self showLoginController];
	}
	
	

}

-(IBAction) updateButtonPressed:(id)sender 
{
	[self pushMessageModal:NingUpdateStatusApi image:nil];
	
}
-(IBAction) addBlogPostButtonPressed:(id)sender 
{
	[self pushMessageModal:NingAddBlogPostApi image:nil];
}


-(void) pushMessageModal:(NSString *)messageType image:(UIImage *)selectedImage {
	NingMessageViewController *ningMessageViewController = [[[NingMessageViewController alloc] initWithNibName:nil
																									   bundle:nil] autorelease];
	ningMessageViewController.NingApiType = messageType;
	ningMessageViewController.selectedImage = selectedImage;
	UINavigationController *placeholderNavigationController = [[UINavigationController alloc]
															   initWithRootViewController:ningMessageViewController];
	[self presentModalViewController:placeholderNavigationController animated:YES];
	[placeholderNavigationController release];	
	
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return !UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DebugLog(@"getting callback from actions sheet. index is %i and cancel button index is:%i", buttonIndex, actionSheet.cancelButtonIndex);
	if( buttonIndex == actionSheet.cancelButtonIndex ) {
		return;
	}	
	if (buttonIndex == 1 ) {
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else if (buttonIndex == 0 ) {
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	[self presentModalViewController:imagePicker animated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	DebugLog(@"image was picked!!!");
	[picker dismissModalViewControllerAnimated:NO];
	[self pushMessageModal:NingAddPhotoApi image:image];
}

-(void)serviceCallBack:(NSDictionary *)responseDictionary {

	NSError *error = [responseDictionary objectForKey:@"error"];
	if( error ) {
		[self showAlertView:[error localizedFailureReason] description:[error localizedDescription]];
		return;
		
	}
	NSDictionary *ningResponse = [responseDictionary objectForKey:@"response"];
	BOOL success = [(NSNumber *)[ningResponse objectForKey:@"success"] boolValue];
	if(!success) {
		[self showAlertView:@"Ning API Error" description:[ningResponse objectForKey:@"reason"]];
		return;
	}
	NSDictionary *profileDictionary = [ningResponse objectForKey:@"entry"];

	//status message and assign it to the label
	NSString *statusMessageText =  [profileDictionary objectForKey:@"statusMessage"];
	statusMessageLabel.text = statusMessageText;
	
	//MEMBER SINCE LABEL
	NSString *createdDateText = [profileDictionary objectForKey:@"createdDate"];
	//there is a bug with the date formatter so i have to replace z with gmt
	createdDateText = [createdDateText stringByReplacingOccurrencesOfString:@"Z" withString:@"GMT"];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	dateFormatter.timeStyle = NSDateFormatterFullStyle;
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
	NSDate *memberSinceDate = [dateFormatter dateFromString:createdDateText];
	[dateFormatter setDateFormat:@"yyyy"];
	NSString *memberSinceText = [dateFormatter stringFromDate:memberSinceDate];
	memberSinceLabel.text =[NSString stringWithFormat:@"Member Since %@", memberSinceText];

	//MEMBER NAME LABEL
	NSString *fullName = [profileDictionary objectForKey:@"fullName"];
	usernameLabel.text = fullName;
	
	//DOWNLOAD THE THUMBNAIL IMAGE
	if( !profileImageView.image ) {
		NSString *profileImageUrlString = [profileDictionary objectForKey:@"iconUrl"];
		AppMakrURLDownload * urlDownload = [[AppMakrURLDownload alloc] initWithURL:profileImageUrlString sender:self 
															selector:@selector(updateProfileImage:urldownload:tag:) 
																	 tag: nil];
		if( !urlDownload ) {
			NSLog(@"error creating url download for profile image");
		}
	}
}
- (void) updateProfileImage:(NSData *)data urldownload:(AppMakrURLDownload *)urldownload tag:(NSObject *)tag {
	DebugLog(@"updating profile image from download callback");
	UIImage *profileImage = [UIImage imageWithData:data];
	profileImageView.image = profileImage;
	[urldownload release];
}
- (void)dealloc 
{  
    [updateStatusButton release];
	[logoutButton release];
	[addBlogPostButton release];
	[uploadPictureButton release];
	[imagePicker release];
	[statusMessageLabel release];
	[usernameLabel release];
	[memberSinceLabel release];										
	[profileImageView release];
	[statusMessageBackgroundView release];	
	[ningService release];
    [super dealloc];
}


@end
