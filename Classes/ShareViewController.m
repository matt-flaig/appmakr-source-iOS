//
//  ShareViewController.m
//  HitFix
//
//  Created by PointAbout Dev on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "URLDownload.h"
#import "CXMLDocument.h"
#import "SA_OAuthTwitterEngine.h"
#import "GlobalVariables.h"
#import "appbuildrAppDelegate.h"

#define kAPPMakerAPPID @"259197467584" 

#define kTwitterOAuthConsumerKey			@"isKX4MLEDtOjAT08cFZMwQ"
#define kTwitterOAuthConsumerSecret			@"sRJda3PwdQBwc93GVMSg6afMqanjrqakenxXc1SOY"

#define kFacebookOAuthConsumerKey			@"17aaa978137d9b24f395cb330198147b"
#define kFacebookOAuthConsumerSecret		@"5ce754ccc0be91cc0ac9d51fcfeb1cb1"

#define kCompanySocialize @"0"
#define kCompanyFacebook @"1"
#define kCompanyTwitter @"2"

// set this to NO to bypass the url shortening sevice of bit.ly
#define BITLY_IS_ENABLED YES

//private stuff
@interface ShareViewController (private)
-(void)postTweet;
-(void)postFacebookFeed;
-(void)setupFacebook;
-(void)setupTwitter;
-(void)showSendButton:(BOOL)show animated:(BOOL)animated;
-(void)cancel;
-(void)send;
-(void)setupFacebookLayout;
@end

@implementation ShareViewController
@synthesize titleBar, toolBar, sendButton, cancelButton, spaceButton, messageView, loginButton, linkTitle, linkUrl;
@synthesize staticUpdateLabel, messageTitleLabel, characterCountLabel,  defaultURL, description, thumbnailURL;
@synthesize delegate;

-(id)initWithServiceType:(shareServiceTypes)type title:(NSString *)title url:(NSString *)url {
	if (self = [super init]) {
		
		//set the service type we are using (facebook, twitter, etc), linkTitle, and linkUrl, and api info
		shareServiceType = type;
		linkTitle = (title) ? [[NSString alloc] initWithString:title] : @"";
		linkUrl = (url) ? [[NSString alloc] initWithString:url] : @"";
		
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
				if ([company isEqualToString:kCompanyFacebook]) {
					facebookApiKey = [[fields objectForKey:@"key"] retain];
					facebookApiSecret = [[fields objectForKey:@"secret"] retain];
				}
			}	
		}
		if (!facebookApiKey || !facebookApiSecret ) {
			facebookApiKey = [kFacebookOAuthConsumerKey retain];
			facebookApiSecret = [kFacebookOAuthConsumerSecret retain];
		}
		if (!twitterApiKey || !twitterApiSecret ) {
			twitterApiKey = [kTwitterOAuthConsumerKey retain];
			twitterApiSecret = [kTwitterOAuthConsumerSecret retain];
			
		}
		//get the status bar hidden status so we can adjust our layout later if needed
		hiddenStatusBar = [UIApplication sharedApplication].statusBarHidden;
		
		//initialize items
		titleBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, (hiddenStatusBar) ? 20 : 0, 320, 44)];
		sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
		cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
		spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		loginButton = [[UIBarButtonItem alloc] init]; //we'll set this up after we log into facebook/twitter
		
		//message view
		messageView = [[UITextView alloc] initWithFrame:CGRectMake(0, 74, 320, (hiddenStatusBar) ? 190 : 170)];
		messageView.backgroundColor = [UIColor whiteColor];
		messageView.font = [UIFont systemFontOfSize:16.0];
		messageView.delegate = self;
		
		//textview title
		messageTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 320, 30)];
		messageTitleLabel.backgroundColor = [UIColor grayColor];
		messageTitleLabel.textColor = [UIColor whiteColor];
		messageTitleLabel.font = [UIFont systemFontOfSize:13.0];
		
		//character count label (currently only used for twitter)
		characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-40, messageView.frame.origin.y + messageView.frame.size.height - 20, 40, 20)];
		characterCountLabel.textAlignment = UITextAlignmentCenter;
		characterCountLabel.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
		characterCountLabel.alpha = 0.8;
		
		//staticUpdateLabel is currently only used for facebook since part of the message is set in a template
		staticUpdateLabel = [[UILabel alloc] init];
		staticUpdateLabel.backgroundColor = [UIColor blackColor];
		staticUpdateLabel.textColor = [UIColor whiteColor];
		staticUpdateLabel.font = [UIFont systemFontOfSize:13.0];
		staticUpdateLabel.numberOfLines = 2;
		
		//change the colors to black
		titleBar.barStyle = UIBarStyleBlack;
		toolBar.barStyle = UIBarStyleBlack;
		
		//keep track of twitter login credentials
		NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
		if ([[defaults objectForKey:@"authData"] length] > 2) {
			isLoggedInToTwitter = YES;
		}
		else {
			isLoggedInToTwitter = NO;
		}
		
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	//show the keyboard if desired
	facebook = ((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook;
	if (shareServiceType == shareServiceTypeFacebook) {
		//we have some special cases for facebook
		[self setupFacebookLayout];
	} else {
		[messageView becomeFirstResponder];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//set default text
	self.title = @"Share...";
	
	//set the background color so that when we aren't showing a keyboard it doesn't look weird
	self.view.backgroundColor = [UIColor blackColor];
	
	//add items to the view
	//toolbar buttons are added in the service setup methods
	[self.view addSubview:titleBar];
	[self.view addSubview:toolBar];
	[self.view addSubview:messageView];
	[self.view addSubview:staticUpdateLabel];
	[self.view addSubview:messageTitleLabel];
	
	//setup service specific items
	switch (shareServiceType) {
		case shareServiceTypeTwitter:
			[self setupTwitter];
			break;
		case shareServiceTypeFacebook:
			[self setupFacebook];
			break;
		default:
			break;
	}
	
    [super viewDidLoad];
	
	//check for invalid data
	if ([linkUrl isEqualToString:@""] || [linkTitle isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Data" message:@"An error occured, either the article title or article URL is null." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[self.view addSubview:alert];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self cancel];
}

-(void)showSendButton:(BOOL)show animated:(BOOL)animated {
	
	NSMutableArray *buttons = [[NSMutableArray alloc] init];
	
	//login button button
	[buttons addObject:loginButton];
	
	//space
	[buttons addObject:spaceButton];
	
	//show or hide the send button
	if (show) {
		[buttons addObject:sendButton];
	}
	
	//cancel button
	[buttons addObject:cancelButton];
	
	//add the buttons
	[toolBar setItems:buttons animated:animated];
	// DebugLog(@" showSendButton - toolbar items are: %@", toolBar.items);
	[buttons release];
}

- (void)cancel {
	/*
	if (isLoggedInToTwitter) {
		//we're logged in so log out
		isLoggedInToTwitter = NO;
		
		[_engine endUserSession];
		[_engine closeAllConnections];
		NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
		[defaults removeObjectForKey:@"authData"];
		[defaults release];	
		loginButton.title = @"Login to Twitter";
		[self showSendButton:NO animated:NO];
	} */
	
	//if the status bar was hidden, show it again
	[[UIApplication sharedApplication] setStatusBarHidden:hiddenStatusBar animated:NO];
	
	//remove this view
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
	//[self release];
}

- (void)send {
	
	//send message with the selected service
	switch (shareServiceType) {
		case shareServiceTypeTwitter:
			[self postTweet];
			DebugLog(@"posting tweet in [send method]");
			break;
		case shareServiceTypeFacebook:
			[self postFacebookFeed];
			break;
		default:
			break;
	}
}

- (void)textViewDidChange:(UITextView *)textView {
	
	//limit tweets to 140 characters
	if (shareServiceType == shareServiceTypeTwitter && [textView.text length] > 140) {
		textView.text = [textView.text substringToIndex:140];
	}
	
	//update the character count label
	if (shareServiceType == shareServiceTypeTwitter) {
		characterCountLabel.text = [NSString stringWithFormat:@"%i", [textView.text length]];
	}
}
	
#pragma mark twitter
-(void)postTweet {	
/*	if(_engine) {
		[_engine sendUpdate: messageView.text];
		[self dismissModalViewControllerAnimated:YES];
		DebugLog(@"dismissing modal view contorller");
		
	}
	else {
		DebugLog(@"[_engine] doesnt exist");*/
		[self showLogin:messageView.text];
//		[self postTweet];
//	}

}

-(void)setupTwitter 
{
	
	//show character count label
	[self.view addSubview:characterCountLabel];

	
	NSString *loginButtonTitle;
	
	if (isLoggedInToTwitter) {
		loginButtonTitle = @"Logout of Twitter";
	}
	else {
		loginButtonTitle = @"Login to Twitter";
	}
	
	//twitter login button
	loginButton = [[UIBarButtonItem alloc] initWithTitle:loginButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(twitterLoginTapped)];

	


	//change the send button text
	sendButton.title = @"Post Tweet";
	
	//messageTitleLabel title
	messageTitleLabel.text = @"  Edit your Twitter message (140 character limit):";
	
	// shorten the URL with bit.ly
	if (([self.linkUrl length] > 20 || [self.linkTitle length] > 95)  && BITLY_IS_ENABLED) {
		
		[self shortenUrl:self.linkUrl];
		
	} else {
		// truncate the title string if its too long and make space for the url
	    [self finishSetup: linkUrl];	
	}
}

#pragma mark facebook
-(void)postFacebookFeed {
	
	//hide the keyboard
	if ([messageView isFirstResponder])
		[messageView resignFirstResponder];
	
	NSDictionary* global = [GlobalVariables getPlist];
	BOOL isAppMakrPublish = [[global objectForKey:@"is_appmakr_publish"] boolValue];

	SBJSON *jsonWriter = [[SBJSON new] autorelease];
	
	NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
														   @"Always Running",@"text",@"http://itsti.me/",@"href", nil], nil];
	
	NSString* attachmentStr;
	
	if(!isAppMakrPublish)
		attachmentStr = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}]}",linkTitle,linkUrl,description,thumbnailURL,linkUrl];
	else
		attachmentStr = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}],\"properties\":{\"Brought to you by\":{\"text\":\"www.AppMakr.com\",\"href\":\"http://www.appmakr.com\"}}}",linkTitle,linkUrl,description,thumbnailURL,linkUrl];
	
	NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];

//	NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
/*	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"Share on Facebook",  @"user_message_prompt",
								   actionLinksStr, @"action_links",
								   attachmentStr, @"attachment",
									nil];
*/
/*	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   attachmentStr, @"message",
								   nil];
*/
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @"hello yellow", @"message",
								   nil];
	
	[facebook requestWithGraphPath:@"/me/feed"
						andParams:params
						andHttpMethod:@"POST"
						andDelegate:self];
	
}

	/*
		FBStreamDialog *dialog = [[[FBStreamDialog alloc] init] autorelease];
		dialog.delegate = self;
		if(!isAppMakrPublish)
			dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}]}",linkTitle,linkUrl,description,thumbnailURL,linkUrl];
		else
			dialog.attachment = [NSString stringWithFormat:@"{\"name\":\"%@\",\"href\":\"%@\",\"description\":\"%@\",\"media\":[{\"type\":\"image\",\"src\":\"%@\",\"href\":\"%@\"}],\"properties\":{\"Brought to you by\":{\"text\":\"www.AppMakr.com\",\"href\":\"http://www.appmakr.com\"}}}",linkTitle,linkUrl,description,thumbnailURL,linkUrl];
		dialog.messageInForm = messageView.text;
		// replace this with a friend's UID
		// dialog.targetId = @"999999";
		[dialog show];
	 */

-(void)setupFacebook {
	
	//setup the facebook session
/*	session = [[FBSession sessionForApplication:facebookApiKey secret: facebookApiSecret delegate:self] retain];	
	[session resume];
	
	//facebook button
	FBLoginButton *fbButton = [[FBLoginButton alloc] initWithFrame:CGRectMake(0, 0, CGRectZero.size.width, CGRectZero.size.height)];
	loginButton = [[UIBarButtonItem alloc] initWithCustomView:fbButton];
	[fbButton release];
	
	//messageTitleLabel title
	messageTitleLabel.text = @"  Enter additional Facebook comments...";
	messageView.text = @"";
 */

	if (!((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook){
		facebook = [[Facebook alloc] initWithAppId:kAPPMakerAPPID];
		((appbuildrAppDelegate *)[UIApplication sharedApplication].delegate).facebook = facebook;
	}
	
	if (![facebook isSessionValid])
		[facebook authorize:_permissions delegate:self];
	
}

-(void)setupFacebookLayout {

	if ([facebook isSessionValid]) {
		//show the keyboard
		[messageView becomeFirstResponder];
		
		//show the send button
		[self showSendButton:YES animated:NO];
	} else {
		//show the fb login
		[loginButton.customView performSelector:@selector(touchUpInside)];
		
		//hide the send button
		[self showSendButton:NO animated:NO];
	}
}


- (void)fbDidLogin {
/*	[self.label setText:@"logged in"];
	_getUserInfoButton.hidden = NO;
	_getPublicInfoButton.hidden = NO;
	_publishButton.hidden = NO;
	_uploadPhotoButton.hidden = NO;
	_fbButton.isLoggedIn = YES;
	[_fbButton updateImage];
 */
	[messageView becomeFirstResponder];
	
	//show the send button
	[self showSendButton:YES animated:YES];
	
	//get the current user's name and setup the staticUpdateLabel in the delegate method
//	NSString *fql_user = [NSString stringWithFormat:@"SELECT first_name FROM user WHERE uid = %lld", facebook.uid];
//	NSMutableDictionary* params_user = [NSMutableDictionary dictionaryWithObject:fql_user forKey:@"query"];
//	[params_user setValue:@"user_query" forKey:@"name"];
//	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params_user];
	
	//change the send button text
	sendButton.title = @"Post to Facebook";
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	DebugLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
/*	[self.label setText:@"Please log in"];
	_getUserInfoButton.hidden    = YES;
	_getPublicInfoButton.hidden   = YES;
	_publishButton.hidden        = YES;
	_uploadPhotoButton.hidden = YES;
	_fbButton.isLoggedIn         = NO;
	[_fbButton updateImage];
 */
	[self showSendButton:NO animated:YES];
	DebugLog(@"facebook isSessionValid %d", [facebook isSessionValid]);

}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
				
				//show these with an animation
				[UIView beginAnimations:nil context:NULL];
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
 
			}
		}
	}
}

/*- (void)sessionDidLogout:(FBSession*)theSession {
	
	//hide the send button
	[self showSendButton:NO animated:YES];
	
	//release the session to clear out our local info
	session = theSession;
}
 */
/*
- (void)session:(FBSession*)newSession didLogin:(FBUID)uid {
	
	//set the class session variable
	session = newSession;
	
	//show the keyboard
	[messageView becomeFirstResponder];
	
	//show the send button
	[self showSendButton:YES animated:YES];
	
	//get the current user's name and setup the staticUpdateLabel in the delegate method
	NSString *fql_user = [NSString stringWithFormat:@"SELECT first_name FROM user WHERE uid = %lld", session.uid];
	NSMutableDictionary* params_user = [NSMutableDictionary dictionaryWithObject:fql_user forKey:@"query"];
	[params_user setValue:@"user_query" forKey:@"name"];
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params_user];
	
	//change the send button text
	sendButton.title = @"Post to Facebook";
}
*/
- (void)dialogDidSucceed:(FBDialog*)dialog {
	
	//posted successfully so exit
	[self cancel];
}

- (void)dialogDidCancel:(FBDialog*)dialog {
	
	//show the keyboard
	[messageView becomeFirstResponder];
	
	//post failed, display an error
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Post to Facebook Failed" message:@"An error occured when posting this story to Facebook. Please try again later."  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
	[self.view addSubview:alert];
	[alert show];
	[alert release];
}

#pragma mark bitly url shortening
-(void)shortenUrl:(NSString *)inputUrl {
	
	self.defaultURL = inputUrl;  // store this locally because it's needed by the callback method.
	NSString * bitlyVersion = @"2.0.1";
	NSString * bitlyLogin   = @"pointabout";
	NSString * bitlyApiKey  = @"R_9309a229de4808872a728ecc64fa8fa7";
	NSString * bitlyFormat  = @"xml";
	NSString * bitlyPost = [NSString stringWithFormat: 
							@"http://api.bit.ly/shorten?version=%@&longUrl=%@&login=%@&apiKey=%@&format=%@",
							bitlyVersion, inputUrl, bitlyLogin, bitlyApiKey, bitlyFormat];
	DebugLog(@" URL to send bitly [%@]", bitlyPost );
	
	// URL ENcode the string
	bitlyPost = [bitlyPost stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	
	
	// !!!: URLDownload was kind of taylor made for downloading images because of which 
	//		the bit.ly response was always rejected and 
	// send the url, get the response back in "receivedData" selector, below
	[[URLDownload alloc] initWithURL:bitlyPost
							  sender:self 
							selector:@selector(receivedData:urldownload:tag:) 
								  tag:0];
}

-(void) receivedDataError {
	DebugLog(@" receivedDataError in ShareViewController.");	
	[[self parentViewController] dismissModalViewControllerAnimated:YES];  // punt
	
}
- (void) receivedData:(id)Data urldownload:(URLDownload *)urldownload tag:(id)Tag {
	// parse the xml string returned from the bit.ly server.
	NSError* error;
	
	DebugLog(@"Data is %@", Data);
	CXMLDocument *doc =	[[CXMLDocument alloc] initWithData:Data options:CXMLDocumentTidyXML error:&error];
	DebugLog(@" SHAREVIEWCONTROLLER - XML Doc returned is %@", doc);
	
	// figure out what nodes are in the doc, and pick it apart with the nodesForXPath call
	NSArray * results =  [doc nodesForXPath:@"/bitly/results/nodeKeyVal/shortUrl" error:&error];
	NSString * finalUrl = self.defaultURL;
	
	if ( [results count] > 0 ) {
		NSString  * shortUrl = [(CXMLElement *)[results objectAtIndex:0] stringValue];
		if ( shortUrl != nil && [shortUrl length]>0 ) {
			finalUrl = shortUrl;
		}
	}
	DebugLog(@"  SHAREVIEWCONROLLER - Bitly response is [%@]", finalUrl );
	[doc release];
	[self finishSetup:finalUrl];
	[urldownload release];
	
}
-(void) finishSetup:(NSString *)url {
	DebugLog(@"FINISHING SETUP");
	
	if ([linkTitle length] > (140 - ([url length]+5))) {
		self.linkTitle = [NSString stringWithFormat:@"%@...", [linkTitle substringToIndex:(140 - ([url length]+5))]];
	}
	
	//twitter text
	messageView.text = [NSString stringWithFormat:@"%@: %@", linkTitle, url];
	
	//show the keyboard
	[messageView becomeFirstResponder];
	
	if (isLoggedInToTwitter) {
		DebugLog(@"SHOWING SEND BUTTON");
		[self showSendButton:YES animated:NO];	
	}
	else {
		DebugLog(@"HIDING SEND BUTTON");
		[self showSendButton:NO animated:NO];	
	}
	
	//	[self showSendButton:NO animated:NO];	
}

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
		loginButton.title = @"Login to Twitter";
		[self showSendButton:NO animated:NO];
		
	} else {	
		//[_engine endUserSession];
//		[_engine closeAllConnections];
//		[_engine clearAccessToken];
		[self showLogin:messageView.text];
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
	loginButton.title = @"Logout of Twitter";
	[self showSendButton:YES animated:YES];
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
		[self cancel];
	}
	DebugLog(@"Request %@ succeeded", requestIdentifier);
	
	[self.delegate shareViewControllerDelegate:self didFinishWithText:messageView.text type:shareServiceType error:nil];
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error 
{
	DebugLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	[self.delegate shareViewControllerDelegate:self didFinishWithText:messageView.text type:shareServiceType error:error];

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
	}
}


#pragma mark cleanup
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[facebook release];
	[titleBar release];
	[toolBar release];
	[sendButton release];
	[cancelButton release];
	[messageView release];	
	[spaceButton release];
	[loginButton release];
	[linkTitle release];
	[linkUrl release];
	[staticUpdateLabel release];
	[messageTitleLabel release];
	
	[twitterApiKey release];
	[twitterApiSecret release];
	[facebookApiKey release];
	[facebookApiSecret release];
	//if self no longer exists, we need to remove it as the delegate from the global facebook session that could be call elsewhere
	
	[_engine release];
	
    [super dealloc];
}

@end
