//
//  ShareModalViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ShareModalViewController.h"

#import "UIView+RoundedCorner.h"
#import "UIView-AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>
#import "CommentViewController.h"
#import "URLDownload.h"
#import "CXMLDocument.h"
#import "SA_OAuthTwitterEngine.h"
#import "GlobalVariables.h"
#import "appbuildrAppDelegate.h"


#define kAPPMakerAPPID @"259197467584" 

#define kTwitterOAuthConsumerKey	@"isKX4MLEDtOjAT08cFZMwQ"
#define kTwitterOAuthConsumerSecret	@"sRJda3PwdQBwc93GVMSg6afMqanjrqakenxXc1SOY"

// set this to NO to bypass the url shortening sevice of bit.ly

#define kCompanySocialize @"0"
#define kCompanyFacebook @"1"
#define kCompanyTwitter @"2"


@interface ShareModalViewController (private)
-(void)postTweet;
-(void)postFacebookFeed:(NSString*)message;
-(void)cancel;
-(void)send;
-(void)setupFacebook;
-(void)fetchFaceBookUserId;
-(void)addViewToWindow:(UIView*)myview;
@end


@implementation ShareModalViewController
@synthesize linkTitle, linkUrl;
@synthesize description, thumbnailURL;
@synthesize entry;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry*)myentry {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.entry = myentry;
		
		// permissions for facebook
		_permissions =  [[NSArray arrayWithObjects:
						  @"read_stream", @"offline_access", @"publish_stream",nil] retain];
		
		NSArray* thirdPartyAuths = [[GlobalVariables getPlist] objectForKey:@"third_party_auths"];
		if( thirdPartyAuths ) {
			for(NSDictionary* thirdPartyAuth in thirdPartyAuths) {
				NSDictionary* fields = [thirdPartyAuth objectForKey:@"fields"];
				NSString* company = [fields	objectForKey:@"company"];
				
				if ([company isEqualToString: kCompanyTwitter]) {
					twitterApiKey =  [[fields objectForKey:@"key"] retain];
					twitterApiSecret = [[fields objectForKey:@"secret"] retain];
				}
			}	
		}
		if (!twitterApiKey || !twitterApiSecret ) {
			twitterApiKey = [kTwitterOAuthConsumerKey retain];
			twitterApiSecret = [kTwitterOAuthConsumerSecret retain];
		}
		
		//keep track of twitter login credentials
		NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
		if ([[defaults objectForKey:@"authData"] length] > 2) {
			isLoggedInToTwitter = YES;
		}
		else {
			isLoggedInToTwitter = NO;
		}
		
		[self setupFacebook];
    }
    return self;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)setupFacebook {
	
	if (!((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook){
		facebook = [[Facebook alloc] initWithAppId:kAPPMakerAPPID];
		facebook.accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
		facebook.expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];
		((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook = facebook;
		[self fetchFaceBookUserId];
	}
}


-(void)fetchFaceBookUserId{

/*	NSString *fql_user = [NSString stringWithFormat:@"SELECT first_name FROM user WHERE uid = %lld", facebook.uid];
	NSMutableDictionary* params_user = [NSMutableDictionary dictionaryWithObject:fql_user forKey:@"query"];
	[params_user setValue:@"user_query" forKey:@"name"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params_user];
*/

}

- (void)viewWillAppear:(BOOL)animated{
	[self.view setRoundedCornerOnHierarchy:5.0f];
	facebook = ((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook;
	
	//check for invalid data
	if ([linkUrl isEqualToString:@""] || [linkTitle isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Data" message:@"An error occured, either the article title or article URL is null." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[self.view addSubview:alert];
		[alert show];
		[alert release];
	}
}


#pragma mark facebook
-(void)postFacebookFeed:(NSString*)message {
	
	NSDictionary* global = [GlobalVariables getPlist];
	BOOL isAppMakrPublish = [[global objectForKey:@"is_appmakr_publish"] boolValue];
	
	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSString* attachmentStr;
	
	if(!isAppMakrPublish)
		attachmentStr = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}]}", linkTitle, linkUrl, description, thumbnailURL,linkUrl];
	else
		attachmentStr = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}],\"properties\":{\"Brought to you by\":{\"text\":\"www.AppMakr.com\",\"href\":\"http://www.appmakr.com\"}}}", linkTitle, linkUrl, description, thumbnailURL, linkUrl];
	
	//	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
	/*	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				 @"Share on Facebook",  @"user_message_prompt",
				 actionLinksStr, @"action_links",
				 attachmentStr, @"attachment",
				 nil];
	*/
	
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				 message, @"message",
				 self.entry.title, @"name",
				 self.entry.url, @"link",
			//	 @"http://www.bello.com/yellow.JPG", @"picture",
				 nil];	 

	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[_modalViewController fadeOutView];
	[appDelegate retainActivityIndicator];
	
	[facebook requestWithGraphPath:@"/me/feed"
						 andParams:params
					 andHttpMethod:@"POST"
					   andDelegate:self];
}

- (void)fbDidLogin {
	//get the current user's name and setup the staticUpdateLabel in the delegate method
    [[NSUserDefaults standardUserDefaults] setObject:facebook.accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:facebook.expirationDate forKey:@"ExpirationDate"];
	[self fetchFaceBookUserId];

	_modalViewController = [[CommentViewController alloc]
							initWithNibName:@"CommentViewController" bundle:nil 
							postType:FacebookShare 
							entry:self.entry];
	
	_modalViewController.modalDelegate = self;
	[_modalViewController show];
}


-(void)fbDidNotLogin:(BOOL)cancelled {
	DebugLog(@"did not login");
}

- (void)fbDidLogout {
	/*	[self.label setText:@"Please log in"];
	 _getUserInfoButton.hidden    = YES;
	 _getPublicInfoButton.hidden   = YES;
	 _publishButton.hidden        = YES;
	 _uploadPhotoButton.hidden = YES;
	 _fbButton.isLoggedIn         = NO;
	 [_fbButton updateImage];
	*/
	DebugLog(@"facebook isSessionValid %d", [facebook isSessionValid]);
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	DebugLog(@"received response");
};

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on the format of the API response.
 * If you need access to the raw response, use
 * (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response.
 */
/*
 - (void)request:(FBRequest *)request didLoad:(id)result {
 if ([result isKindOfClass:[NSArray class]]) {
 result = [result objectAtIndex:0];
 }
 if ([result objectForKey:@"owner"]) {
 //	[self.label setText:@"Photo upload Success"];
 } else {
 //	[self.label setText:[result objectForKey:@"name"]];
 }
 };
 */

/**
 * Called when an error prevents the Facebook API request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	DebugLog(@"request didFailWithError %@",[error localizedDescription]);

	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate releaseActivityIndicator];
};


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	//	[self.label setText:@"publish successfully"];
}

// FBRequestDelegate
- (void)request:(FBRequest*)request didLoad:(id)result {
	
	//user query
	if ([request.params valueForKey:@"name"] == @"user_query") {
		
		//was anything returned?
		if ([result count] > 0) {
			
			//get the user from the query
			NSDictionary *user = [result objectAtIndex:0];
			
			//check that the name is not null
			if (![[user objectForKey:@"first_name"] isKindOfClass:[NSNull class]]) {
				_facebookUsername = [user objectForKey:@"first_name"];
				//_facebookUsername = [NSString stringWithFormat:@"  Message Preview:\n  \"%@ shared this link: %@\"", [user objectForKey:@"first_name"], self.linkTitle]; 
				[_facebookUsername retain];
				if (_modalViewController != nil)
					((CommentViewController*)_modalViewController).username = _facebookUsername;
				
//				staticUpdateLabel.text = [NSString stringWithFormat:@"  Message Preview:\n  \"%@ shared this link: %@\"", [user objectForKey:@"first_name"], self.linkTitle];
//				staticUpdateLabel.frame = CGRectMake(0, toolBar.frame.size.height, self.view.frame.size.width, 50);

				//show these with an animation
/*				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.25];
				
				//staticUpdateLabel shows the user the part of the feed update that they can't change
				staticUpdateLabel.text = [NSString stringWithFormat:@"  Message Preview:\n  \"%@ shared this link: %@\"", [user objectForKey:@"first_name"], self.linkTitle];
				staticUpdateLabel.frame = CGRectMake(0, toolBar.frame.size.height, self.view.frame.size.width, 50);
				
				//move the messagetitlelabel
				messageTitleLabel.frame = CGRectMake(messageTitleLabel.frame.origin.x, staticUpdateLabel.frame.origin.y + staticUpdateLabel.frame.size.height, messageTitleLabel.frame.size.width, messageTitleLabel.frame.size.height);
				
				//resize the textview so that everything fits nicely
				messageView.frame = CGRectMake(messageView.frame.origin.x, messageTitleLabel.frame.origin.y + messageTitleLabel.frame.size.height, messageView.frame.size.width, messageView.frame.size.height - staticUpdateLabel.frame.size.height);
				
				//end animation
				[UIView commitAnimations];
*/
			}
		}
	}
	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate releaseActivityIndicator];

}
#pragma mark -


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self cancelPressed:self.view];
}

-(IBAction)cancelPressed:(id)sender{
	[modalDelegate dismissModalView:self.view];
}

-(IBAction)shareThisTouched:(id)sender{
	[modalDelegate dismissModalView:self.view];
}

-(IBAction)shareOnFacebookTouched:(id)sender{

	if (![facebook isSessionValid]){
		[facebook authorize:_permissions delegate:self];
		return;
	}
	
	_modalViewController = [[CommentViewController alloc]
							initWithNibName:@"CommentViewController" bundle:nil 
							postType:FacebookShare 
							entry:self.entry];
	
	_modalViewController.modalDelegate = self;
	[_modalViewController show];

}

-(IBAction)shareOnTwitterTouched:(id)sender{
	
	if (!isLoggedInToTwitter){
		[self showLogin:@" "];
	}
	else {
		_modalViewController = [[CommentViewController alloc]
								initWithNibName:@"CommentViewController" bundle:nil postType:TwitterShare entry:self.entry];
		
		_modalViewController.modalDelegate = self;	
		[_modalViewController show];
	}
}

#pragma mark SocializeModalViewCallbackDelegate
-(void)dismissModalView:(UIView*)myView andPostComment:(NSString*)comment forEntry:(Entry*)entry{
/*	[_modalViewController fadeOutView];
	[theFeedService postComment:comment forEntry:entry];
	
	// app builder delegate
	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[self.view setUserInteractionEnabled:NO];
	[appDelegate retainActivityIndicator];
*/
}

-(void)dismissModalView:(UIView*)myView andPostToFacebook:(NSString*)comment{
	//facebook
	[self postFacebookFeed:comment]; 
}

-(void)dismissModalView:(UIView*)myView andPostToTwitter:(NSString*)comment{

	[self showLogin:comment]; 
}

-(void)dismissModalView:(UIView*)myView {
	[_modalViewController fadeOutView];
	[_modalViewController release];
}

-(void)dismissModalView:(UIView*)myView andPushNewModalController:(UIViewController*)newSocializeModalController{
/*	[_modalViewController fadeOutView];
	[_modalViewController release];
	
	_modalViewController =	[newSocializeModalController retain];
	((SocializeModalViewController*)_modalViewController).modalDelegate = self;
	[_modalViewController show];
 */
}

#pragma mark -


#pragma mark TwitterLoginStuff
-(void)twitterLoginTapped {
	
	if (isLoggedInToTwitter) { //logout button is pressed, perform logout of the twitter account
		
		NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		NSArray* theCookies = [cookieStorage cookiesForURL:[NSURL URLWithString:@"http://twitter.com/oauth"]];
		
		for (NSHTTPCookie *cookie in theCookies) {
			[cookieStorage deleteCookie:cookie];
		}
		
		//we're logged in so log out
		isLoggedInToTwitter = NO;
		_engine = nil;
		[_engine endUserSession];
		[_engine closeAllConnections];
		[_engine clearAccessToken];
		NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
		[defaults removeObjectForKey:@"authData"];
		[defaults release];	
		
	} else {	
//		[self showLogin:messageView.text];
	}	
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	if (isLoggedInToTwitter) {
		return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
	}
	else 
	{
		return @"";
	}
}
//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
	DebugLog(@"Authenicated for %@", username);
	isLoggedInToTwitter = YES;
//	loginButton.title = @"Logout of Twitter";
//	[self showSendButton:YES animated:YES];
	_modalViewController = [[CommentViewController alloc]
							initWithNibName:@"CommentViewController" bundle:nil postType:TwitterShare entry:self.entry];
	
	_modalViewController.modalDelegate = self;	
	[_modalViewController show];
	
}

- (void) OAuthTwitterControllerFailed:(SA_OAuthTwitterController *) controller {
	DebugLog(@"Authentication Failed!");
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	DebugLog(@"Authentication Canceled.");
}


//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	if (isLoggedInToTwitter) {
		appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
		[appDelegate releaseActivityIndicator];
		[_modalViewController release];
	}
	DebugLog(@"Request %@ succeeded", requestIdentifier);
//	[self.delegate shareViewControllerDelegate:self didFinishWithText:messageView.text type:shareServiceType error:nil];
}

- (void)requestFailed: (NSString *) requestIdentifier withError: (NSError *) error 
{
	DebugLog(@"Request %@ failed with error: %@", requestIdentifier, error);
//	[self.delegate shareViewControllerDelegate:self didFinishWithText:messageView.text type:shareServiceType error:error];
	[self releaseActivityIndicatorMiddleOfView];
}

//=============================================================================================================================
#pragma mark ViewController Stuff
- (void)showLogin:(NSString *)tweetString{
	UIViewController *controller;
	
	if (_engine) {
		DebugLog(@"engine exists -- returning");
		//		isLoggedInToTwitter = YES;
		//		loginButton.title = @"Logout of Twitter";
		//		[self showSendButton:YES animated:YES];
	}
	else {
		DebugLog(@"engine doesnt exist, -- continuing");
		DebugLog(@"entered show loging");
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = twitterApiKey;
		_engine.consumerSecret = twitterApiSecret;
	}
	
	[_engine requestRequestToken];
	
	controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else 
	{
		//[self dismissModalViewControllerAnimated:YES];
		DebugLog(@"dismissing modal view contorller");
		[_engine sendUpdate: tweetString];

		appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
		[_modalViewController fadeOutView];
		[appDelegate retainActivityIndicator];
	}
}

#pragma mark cleanup


#pragma mark -
#pragma mark CAAnimation Delegate Methods

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
 //   [self.commentVeiw becomeFirstResponder];
}

#pragma mark -
- (IBAction)emailThisTouched:(id)sender{
/*	
	[modalDelegate dismissModalView:self.view];
	[modalDelegate shareViaEmail];
*/
	
	Link * link = [[entry linksInOriginalOrder] objectAtIndex:0];
	NSDictionary* global = [GlobalVariables getPlist];
	BOOL isAppMakrPublish = [[global objectForKey:@"is_appmakr_publish"] boolValue];
	
	mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
	[mailController setSubject:[NSString stringWithFormat:@"%@",entry.title]];

	if(!isAppMakrPublish)
		[mailController setMessageBody:[NSString stringWithFormat:@"I thought you would find this interesting:<br /><br />%@ - <a href=\"%@\">%@</a><br /><br />Shared from %@, an iPhone app.",entry.title,link.href,link.href,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] isHTML:YES];
	else
		[mailController setMessageBody:[NSString stringWithFormat:@"I thought you would find this interesting:<br /><br />%@ - <a href=\"%@\">%@</a><br /><br />Shared from %@, an iPhone app made with <a href=\"http://www.appmakr.com\">www.AppMakr.com</a>",entry.title,link.href,link.href,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] isHTML:YES];

	[self addViewToWindow:mailController.view];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[mailController.view  removeFromSuperview];
}

-(void)addViewToWindow:(UIView*)myview{
	[[((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate) window] addSubview:myview];
	[myview doPopInAnimationWithDelegate:nil];
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
	self.entry = nil;
    [super dealloc];
}
@end
