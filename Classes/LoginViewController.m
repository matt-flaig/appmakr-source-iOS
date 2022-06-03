    //
//  LoginViewController.m
//  appbuildr
//
//  Created by William M. Johnson on 7/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "LoginViewController.h"
#import "ASIFormDataRequest.h"
#import "NSDictionary_JSONExtensions.h"


@interface LoginViewController ()

-(void) loginWithUsername:(NSString *)username AndPassword:(NSString *)password;

//FUTURE: Login could fail for reasons other than username/password.  Modify this 
//so that you can pass in failure reason messages
-(void) loginFailed;
-(void) processLoginInfo:(NSDictionary *)loginInfo;

@end



@implementation LoginViewController


@synthesize delegate;
@synthesize loginURL;

- (void)dealloc 
{
	[usernameField release];
	[passwordField release];
	[loginFailedAlertView release];
	[loginURL release];
    [super dealloc];
}

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{ 
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	loginInProgressView =nil;
	loginFailedAlertView = nil;
	
	
	UIImage * iconImage = [UIImage imageNamed:@"Icon.png"];
	UIImageView * iconView = [[UIImageView alloc]initWithImage:iconImage];
	
	CGRect viewFrame = self.view.bounds;
	iconView.frame = CGRectMake((viewFrame.size.width - iconImage.size.width)/2, 40, iconImage.size.width, iconImage.size.height);
	[self.view addSubview:iconView];
	[iconView release];
	
	usernameField  = [[UITextField alloc]initWithFrame:CGRectMake(10, 110, 300,40)];
	usernameField.delegate = self;
	usernameField.keyboardType = UIKeyboardTypeEmailAddress;
	usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	usernameField.returnKeyType = UIReturnKeyGo;
	usernameField.borderStyle = UITextBorderStyleRoundedRect;
	usernameField.backgroundColor = [UIColor clearColor];
	usernameField.adjustsFontSizeToFitWidth = YES;
	usernameField.minimumFontSize = 12;
	usernameField.font = [usernameField.font fontWithSize:24];
	usernameField.placeholder = @"Username";
	
	passwordField  = [[UITextField alloc]initWithFrame:CGRectMake(10, 160, 300, 40)];
	passwordField.secureTextEntry = YES;
	passwordField.delegate = self;
	passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	passwordField.returnKeyType = UIReturnKeyGo;
	passwordField.borderStyle = UITextBorderStyleRoundedRect;
	passwordField.backgroundColor = [UIColor clearColor];
	passwordField.adjustsFontSizeToFitWidth = YES;
	passwordField.minimumFontSize = 12;
	passwordField.font = [passwordField.font fontWithSize:24];
	passwordField.placeholder =@"Password";
	
	[self.view addSubview:usernameField];
	[self.view addSubview:passwordField];
	//[self.view addSubview:loginButton];
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSInteger index = buttonIndex;
	
	switch (index) 
	{
		case 0:  //ok
			[usernameField becomeFirstResponder];
			break;
		default:
			break;
	}
	
	[alertView release];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	NSInteger halfTheSquare = 150;	
	loginInProgressView = [[SendingMessageView alloc] 
						  initWithFrame:CGRectMake(self.view.center.x - 75,self.view.center.y-halfTheSquare,halfTheSquare,halfTheSquare)];	
	
	loginInProgressView.labelView.text = @"Loggin in. . .";
	
	[self.view addSubview:loginInProgressView];
	[self loginWithUsername:usernameField.text AndPassword:passwordField.text];
	return YES;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
	return YES;	
}

- (void)viewWillAppear:(BOOL)animated
{
	[usernameField becomeFirstResponder];
	
}



-(void) loginWithUsername:(NSString *)username AndPassword:(NSString *)password
{
	NSURL* url = [NSURL URLWithString:self.loginURL];
	DebugLog(@"url is %@", url);
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.delegate = self;
	
	[request setPostValue:username forKey:@"username"];
	[request setPostValue:password forKey:@"password"];
	[request startAsynchronous];
	DebugLog(@"submitting request for send message");
}


//FUTURE: Login could fail for reasons other than username/password.  Modify this 
//so that you can pass in failure reason messages
-(void) loginFailed
{
	loginFailedAlertView = [[UIAlertView alloc]initWithTitle:@"Login Failed"
													 message:@"Invalid username/password combination."   
													delegate:nil
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[loginFailedAlertView show]; 
	
}

#pragma mark ASI delegate calls 
- (void)requestFinished:(ASIHTTPRequest *)request
{
	[loginInProgressView removeFromSuperview];
	[loginInProgressView release];
	loginInProgressView = nil;
	
	NSError * error = nil;
	NSDictionary * responseDictionary = [NSDictionary dictionaryWithJSONData:[request responseData] error:&error];
	
	if (error) 
	{
		[self loginFailed];
	}
	else 
	{
		id userIsAuthenticated = [responseDictionary objectForKey:@"authenticated"];
		
		if (!userIsAuthenticated || (userIsAuthenticated == [NSNull null]) || ([((NSNumber*)userIsAuthenticated) boolValue] == NO)) 
		{
			[self loginFailed];
			return;
		}
		
		[self processLoginInfo:responseDictionary];
		[self.delegate loginViewController:self didAuthenticate:[((NSNumber*)userIsAuthenticated) boolValue]];
		
		
	}

}

-(void) processLoginInfo:(NSDictionary *)loginInfo
{
	BOOL encryptionKeyIsSet = NO;
	
    
	
	id encryptionKey = [loginInfo valueForKey:@"encryption_key"];
	
	
	if (encryptionKey && (encryptionKey != [NSNull null]) )
	{
	    DebugLog(@"encryption key:\n%@",(NSString *)encryptionKey);
		KeychainItemWrapper *secretKeyWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"_application_secret_key" accessGroup:nil];
		[secretKeyWrapper resetKeychainItem];
		[secretKeyWrapper setObject:@"Messge_Send" forKey:(id)kSecAttrAccount]; 
		[secretKeyWrapper setObject:(NSString *)encryptionKey  forKey:(id)kSecValueData];
		[secretKeyWrapper release];
		encryptionKeyIsSet = YES;
		
		
	}
	
	[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:encryptionKeyIsSet] forKey:@"encryption_key_set"];
	
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	[self loginFailed];
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


@end
