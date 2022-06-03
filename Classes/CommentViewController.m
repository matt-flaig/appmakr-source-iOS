//
//  CommentViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/18/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "CommentViewController.h"
#import "UIView+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>
#import "appbuildrAppDelegate.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "FacebookWrapper.h"
#import "CXMLDocument.h"
#import "ErrorDescription.h"
#import "GlobalVariables+Twitter.h"
/*
#define kTwitterOAuthConsumerKey	@"isKX4MLEDtOjAT08cFZMwQ"
#define kTwitterOAuthConsumerSecret	@"sRJda3PwdQBwc93GVMSg6afMqanjrqakenxXc1SOY"

#define BITLY_IS_ENABLED YES

// set this to NO to bypass the url shortening sevice of bit.ly

#define kCompanySocialize @"0"
#define kCompanyFacebook @"1"
#define kCompanyTwitter @"2"
*/


@interface CommentViewController (private) 
-(void)postFacebookFeed:(NSString*)message;
-(void)cancel;
-(void)send;
-(void)setupFacebook;
-(void)addViewToWindow:(UIView*)myview;
-(void)showLoginScreen;
-(void)showLogin:(NSString *)tweetString;
-(void)finishSetup:(NSString *)url;
-(void)shortenUrl:(NSString *)inputUrl;
-(void)fillErrorsCodeDescriptionForTwitter;
@end

@implementation CommentViewController

@synthesize commentVeiw;
@synthesize entry;
@synthesize	titleLabel;
@synthesize	twitterCharCountLabel;
@synthesize	commentText;
@synthesize tmpBitlyURlString;
@synthesize facebookMessagePreviewLabel;
@synthesize attachedLinkImageView;
@synthesize submitButton;
@synthesize cancelButton;


-(NSString*)username{
	return username;
}

-(void)setUsername:(NSString *)myusername{
	
	if (username != nil){
		[username release];
		username = myusername;
		[username retain];
	}
	else {
		username = myusername;
		[username retain];
	}
}

-(void)fillErrorsCodeDescriptionForTwitter
{
    twitterErrorsCodeDesciption = [[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ErrorDescription descriptionWithTitle:@"OK" body:@"Succes."], [NSNumber numberWithInt: 200], 
                                    [ErrorDescription descriptionWithTitle:@"Not Modified" body:@"There was no new data to return."], [NSNumber numberWithInt: 304], 
                                    [ErrorDescription descriptionWithTitle:@"Bad Request" body:@"The request was invalid. An accompanying error message will explain why. This is the status code will be returned during rate limiting."], [NSNumber numberWithInt: 400], 
                                    [ErrorDescription descriptionWithTitle:@"Unauthorized" body:@"Authentication credentials were missing or incorrect."], [NSNumber numberWithInt: 401], 
                                    [ErrorDescription descriptionWithTitle:@"Whoops!" body:@"You already tweeted that..."], [NSNumber numberWithInt: 403], 
                                    [ErrorDescription descriptionWithTitle:@"Not Found" body:@"The URI requested is invalid or the resource requested, such as a user, does not exists."], [NSNumber numberWithInt: 404], 
                                    [ErrorDescription descriptionWithTitle:@"Not Acceptable" body:@"Returned by the Search API when an invalid format is specified in the request."], [NSNumber numberWithInt: 406], 
                                    [ErrorDescription descriptionWithTitle:@" Enhance Your Calm" body:@"Returned by the Search and Trends API when you are being rate limited."], [NSNumber numberWithInt: 420], 
                                    [ErrorDescription descriptionWithTitle:@"Internal Server Error" body:@"Something is broken. Please post to the group so the Twitter team can investigate."], [NSNumber numberWithInt: 500], 
                                    [ErrorDescription descriptionWithTitle:@"Bad Gateway" body:@"Twitter is down or being upgraded."], [NSNumber numberWithInt: 502], 
                                    [ErrorDescription descriptionWithTitle:@"Service Unavailable" body:@"The Twitter servers are up, but overloaded with requests. Try again later."], [NSNumber numberWithInt: 503], 
                                    nil]retain];
}

-(id)initWithNibName:(NSString *)nibNameOrNil 
			  bundle:(NSBundle *)nibBundleOrNil 
			postType:(SocializePostType)postType
			   entry:(Entry*)myentry	{

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		// Custom initialization
		theService = [[AppMakrSocializeService alloc ] init];
		_postType = postType;
        self.entry = (Entry*)[theService.localDataStore entityWithID:myentry.objectID];
		//self.entry = myentry;
		isAuthDialogCancelled = NO;
		
		if ([self.entry.url isEqualToString:@""] || [self.entry.title isEqualToString:@""]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Data" message:@"An error occured, either the article title or article URL is null." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
			[self.view addSubview:alert];
			[alert show];
			[alert release];
		}
		
		switch (_postType) {
				
			case TwitterShare:
				self.twitterCharCountLabel.hidden = NO;
				self.twitterCharCountLabel.text = @"140";
				if (([self.entry.url length] > 20 || [self.entry.title length] > 95)  && BITLY_IS_ENABLED) {
					[self shortenUrl:self.entry.url];
				} else 
					// truncate the title string if its too long and make space for the url
					[self finishSetup: self.entry.url];
				break;

			case SocializeCommentOption:
				self.commentText = @"";
				break;

			case FacebookShare:
				self.commentText = @"";
				break;

			default:
				break;
		}
		
		if (_postType == TwitterShare)
			self.twitterCharCountLabel.hidden = NO;
		
		
		// permissions for facebook
		_facebookPermissions =  [[NSArray arrayWithObjects:
						  @"read_stream", @"offline_access", @"publish_stream",nil] retain];
        [self setupFacebook];
		
        NSPair* twiterApi = [GlobalVariables twitterApiKeySecret];
        twitterApiKey = twiterApi.first;
        twitterApiSecret = twiterApi.second;
		
		//keep track of twitter login credentials
		NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
		if ([[defaults objectForKey:@"authData"] length] > 2) {
			isLoggedInToTwitter = YES;
		}
		else 
			isLoggedInToTwitter = NO;
		
		//[self setupFacebook];
        [self fillErrorsCodeDescriptionForTwitter];
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[super viewDidLoad];
	self.commentVeiw.delegate = self;
	
	switch (_postType) {

		case TwitterShare:
			self.titleLabel.text = @"Twitter";
			self.twitterCharCountLabel.hidden = NO;
			self.twitterCharCountLabel.text = @"140";
			self.commentVeiw.text = self.commentText;
			break;

		case SocializeCommentOption:
			self.commentVeiw.text = self.commentText;
			break;
			
		case FacebookShare:
			self.titleLabel.text = @"Facebook";
			self.commentVeiw.text = self.commentText;
			self.attachedLinkImageView.hidden = NO;
			break;
		
		default:
			break;
	}
	
	//setting rounded corners
	commentVeiw.layer.cornerRadius = 5.0f;
	alertView.layer.cornerRadius = 5.0f;
	submitButton.layer.cornerRadius	= 5.0f;
	twitterCharCountLabel.layer.cornerRadius = 10.0f;
	attachedLinkImageView.layer.cornerRadius = 10.0f;
        
}

-(void)viewDidAppear:(BOOL)animated{
	
	if (isAuthDialogCancelled){
		[modalDelegate dismissModalView:self.view];
		return;
	}
	
	[super viewDidAppear:animated];
	   
	switch (_postType) {
			
		case TwitterShare:
			[self.commentVeiw becomeFirstResponder];
            if(!isLoggedInToTwitter)
                [self  performSelector:@selector(showLoginScreen) withObject:nil afterDelay:0.1];
			break;
			
		case SocializeCommentOption:
			break;
			
		case FacebookShare:
			if (![[FacebookWrapper facebook] isSessionValid]){
                //TESTING
                _isAuthRequest = YES;
                //
                [[FacebookWrapper facebook] authorize:_facebookPermissions delegate:self];
			}
			else
				[self.commentVeiw becomeFirstResponder];
				
			break;
			
		default:
			break;
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[modalDelegate dismissModalView:self.view];
}

- (void)viewDidUnload {

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (void)viewWillAppear:(BOOL)animated{
	//check for invalid data
	[super viewWillAppear:animated];
    
    //TODO:: delete this. This is duble check
	if ([self.entry.url isEqualToString:@""] || [self.entry.title isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Data" message:@"An error occured, either the article title or article URL is null." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
		[self.view addSubview:alert];
		[alert show];
		[alert release];
	} 
}


-(IBAction)cancelPressed:(id)sender{

	[modalDelegate dismissModalView:self.view];
}

-(IBAction)submitCommentTouched:(id)sender{

	if (_postType == SocializeCommentOption){
		[modalDelegate dismissModalView:self.view andPostComment:commentVeiw.text forEntry:self.entry];
	}
	else if (_postType == TwitterShare){
		if (isLoggedInToTwitter)
			self.alertView.userInteractionEnabled = NO;
		[self showLogin:commentVeiw.text]; 
	}
	else if (_postType == FacebookShare){

		if (![[FacebookWrapper facebook] isSessionValid]){
			[[FacebookWrapper facebook] authorize:_facebookPermissions delegate:self];
		}
		else{
			self.alertView.userInteractionEnabled = NO;
			[self postFacebookFeed:commentVeiw.text]; 
		}
	}
}

#pragma mark CAAnimation Delegate Methods

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    //[self.commentVeiw becomeFirstResponder];
}

#pragma mark -

#pragma mark bitly url shortening

-(void)shortenUrl:(NSString *)inputUrl {
	
	self.tmpBitlyURlString = inputUrl;  // store this locally because it's needed by the callback method.
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
	
	// !!!: AppMakrURLDownload was kind of taylor made for downloading images because of which 
	//		the bit.ly response was always rejected and 
	// send the url, get the response back in "receivedData" selector, below
	[[AppMakrURLDownload alloc] initWithURL:bitlyPost
							  sender:self 
							selector:@selector(receivedData:urldownload:tag:) 
								 tag:0];
}

-(void) receivedDataError {
	DebugLog(@" receivedDataError in ShareViewController.");	
	[[self parentViewController] dismissModalViewControllerAnimated:YES];  // punt
}

- (void) receivedData:(id)Data urldownload:(AppMakrURLDownload *)urldownload tag:(id)Tag {
	// parse the xml string returned from the bit.ly server.
	NSError* error;
	
	DebugLog(@"Data is %@", Data);
	CXMLDocument *doc =	[[CXMLDocument alloc] initWithData:Data options:CXMLDocumentTidyXML error:&error];
	DebugLog(@" SHAREVIEWCONTROLLER - XML Doc returned is %@", doc);
	
	// figure out what nodes are in the doc, and pick it apart with the nodesForXPath call
	NSArray * results =  [doc nodesForXPath:@"/bitly/results/nodeKeyVal/shortUrl" error:&error];
	NSString * finalUrl = self.tmpBitlyURlString;
	
	if ( [results count] > 0 ) {
		NSString  * shortUrl = [(CXMLElement *)[results objectAtIndex:0] stringValue];
		if ( shortUrl != nil && [shortUrl length]>0 ) {
			finalUrl = shortUrl;
		}
	}
	DebugLog(@"  COMMENTVIEWCONTROLLER - Bitly response is [%@]", finalUrl );
	[doc release];
	[self finishSetup:finalUrl];
	[urldownload release];
}

-(void) finishSetup:(NSString *)url {

	DebugLog(@"FINISHING SETUP");
	NSString *tmpTitle;
	tmpTitle = self.entry.title;

	if ([tmpTitle length] > (140 - ([url length]+5))) {
		tmpTitle = [NSString stringWithFormat:@"%@...", [self.entry.title substringToIndex:(140 - ([url length]+5))]];
	}
	
	commentVeiw.text = self.commentText = [NSString stringWithFormat:@"%@: %@", tmpTitle, url];
	self.twitterCharCountLabel.text = [NSString stringWithFormat:@"%i", [self.commentText length]];

}

#pragma mark -


#pragma TextView Delegate 

- (void)textViewDidChange:(UITextView *)textView {
	
	//limit tweets to 140 characters
	if (_postType == TwitterShare && [textView.text length] > 140) {
		textView.text = [textView.text substringToIndex:140];
	}
	
	//update the character count label
	if (_postType == TwitterShare) {
		twitterCharCountLabel.text = [NSString stringWithFormat:@"%i", 140 - [textView.text length]];
	}
}

#pragma mark - 

/****************************/

-(void)setupFacebook {
	
	[FacebookWrapper facebook].accessToken    = [[NSUserDefaults standardUserDefaults] stringForKey:@"AccessToken"];
	[FacebookWrapper facebook].expirationDate = (NSDate *) [[NSUserDefaults standardUserDefaults] objectForKey:@"ExpirationDate"];

}

#pragma mark facebook

-(void)postFacebookFeed:(NSString*)message {
	
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   message, @"message",
								   self.entry.title, @"name",
								   self.entry.url, @"link",
								   nil];	 
	
	[self retainActivityIndicatorMiddleOfView];
	
	[[FacebookWrapper facebook] requestWithGraphPath:@"/me/feed"
						 andParams:params
					 andHttpMethod:@"POST"
					   andDelegate:self];
}

- (void)fbDidLogin {
	//get the current user's name and setup the staticUpdateLabel in the delegate method
    [[NSUserDefaults standardUserDefaults] setObject:[FacebookWrapper facebook].accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:[FacebookWrapper facebook].expirationDate forKey:@"ExpirationDate"];
	[self.commentVeiw becomeFirstResponder];
    
    if (![theService userIsAuthenticatedWithProfileInfo])
        [[FacebookWrapper facebook] requestWithGraphPath:@"me" andDelegate:self];
}


-(void)fbDidNotLogin:(BOOL)cancelled {
	isAuthDialogCancelled = YES;
	DebugLog(@"did not login");
	[modalDelegate dismissModalView:self.view];
}

- (void)fbDidLogout {
	DebugLog(@"facebook isSessionValid %d", [[FacebookWrapper facebook] isSessionValid]);
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
	
	[self releaseActivityIndicatorMiddleOfView];
	self.alertView.userInteractionEnabled = YES;
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
													message: [error localizedDescription]
												   delegate: nil 
										  cancelButtonTitle: NSLocalizedString(@"OK", @"")
										  otherButtonTitles: nil];
	[alert show];	
	[alert release];
};


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */


- (void)dialogDidComplete:(FBDialog *)dialog {
	//	[self.label setText:@"publish successfully"];
}

- (void)setVariablesForTest:(BOOL)value {
    _isAuthRequest = value;
    theService = [[AppMakrSocializeService alloc] init];
}

- (void)serviceAuthenticationWithThirdPartyCreds:(NSString*)vUserId {
    [theService authenticateWithThirdPartyCreds:vUserId accessToken:[FacebookWrapper facebook].accessToken];
}

- (void)servicePostCommentFromRequestDidLoadMethod {
    [theService postComment:commentVeiw.text forEntry:entry commentType:COMMENT_MEDIUM_FACEBOOK];
}

// FBRequestDelegate
- (void)request:(FBRequest*)request didLoad:(id)result {
	
	//user query
    if ([result count] > 0) {
        
        //get the user from the query
        if ([result isKindOfClass:[NSDictionary class]]){
            DebugLog(@"result class info %@ ", result );
            NSDictionary *user = result;
            
            if (_isAuthRequest) {
                //check that the name is not null
                if (![[user objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
                    
                    _facebookUsername = [user objectForKey:@"id"];

                    [self serviceAuthenticationWithThirdPartyCreds:_facebookUsername];
                    //[theService authenticateWithThirdPartyCreds:_facebookUsername accessToken:[FacebookWrapper facebook].accessToken];
                }
                _isAuthRequest = NO;
            }
            else {
                [self servicePostCommentFromRequestDidLoadMethod];
                //[theService postComment:commentVeiw.text forEntry:entry commentType:COMMENT_MEDIUM_FACEBOOK];
                [self releaseActivityIndicatorMiddleOfView];
                [modalDelegate dismissModalView:self.view];
            }
        }
    }
	else {
		DebugLog(@" Printing out the requests name %@ ", [request.params valueForKey:@"name"]);
		DebugLog(@" Printing out the request %@ ", request);
//		[self releaseActivityIndicatorMiddleOfView];
	}
}
#pragma mark -

 
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
		//	[self showLogin:messageView.text];
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
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) myusername {
	DebugLog(@"Authenicated for %@", myusername);
	isLoggedInToTwitter = YES;
}

- (void) OAuthTwitterControllerFailed:(SA_OAuthTwitterController *) controller {
	DebugLog(@"Authentication Failed!");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
													message: NSLocalizedString(@"Authentication Failed!", @"")
												   delegate: nil 
										  cancelButtonTitle: NSLocalizedString(@"OK", @"")
										  otherButtonTitles: nil];
	[alert show];	
	[alert release];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	DebugLog(@"Authentication Canceled.");
	isAuthDialogCancelled = YES;
	//[modalDelegate dismissModalView:self.view];
}
//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	self.alertView.userInteractionEnabled = YES;

	[self releaseActivityIndicatorMiddleOfView];
	DebugLog(@"Request %@ succeeded", requestIdentifier);
	[theService postComment:commentVeiw.text forEntry:entry  commentType:COMMENT_MEDIUM_TWITTER];
	[self  performSelector:@selector(dismissMyself) withObject:nil afterDelay:0.2];
	
}

- (void)requestFailed: (NSString *) requestIdentifier withError: (NSError *) error 
{
	DebugLog(@"Request %@ failed with error: %@", requestIdentifier, error);
	//	[self.delegate shareViewControllerDelegate:self didFinishWithText:messageView.text type:shareServiceType error:error];
	self.alertView.userInteractionEnabled = YES;
	[self releaseActivityIndicatorMiddleOfView];

    NSString* title = nil;
    NSString* message = nil;
    ErrorDescription*descritipn = [twitterErrorsCodeDesciption objectForKey:[NSNumber numberWithInt:error.code]];
    if(descritipn)
    {
        title = descritipn.title;
        message = descritipn.body;
    }
    else
    {
        title = NSLocalizedString(@"Failed!", @"") ;
        message = [error localizedDescription];
    }
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title 
													message: message
												   delegate: nil 
										  cancelButtonTitle: NSLocalizedString(@"OK", @"")
										  otherButtonTitles: nil];

	[alert show];	
	[alert release];
}


-(void)dismissMyself{
	[modalDelegate dismissModalView:self.view];
}

//=============================================================================================================================
#pragma mark ViewController Stuff
- (void)showLogin:(NSString *)tweetString{

	UIViewController *controller;
	
	if (_engine) {
		DebugLog(@"engine exists -- returning");
	}
	else {
		DebugLog(@"engine doesnt exist, -- continuing");
		DebugLog(@"entered show loging");
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = twitterApiKey;
		_engine.consumerSecret = twitterApiSecret;
	}
	
	//[_engine requestRequestToken];
	
	controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else 
	{
		//[self dismissModalViewControllerAnimated:YES];
		[_engine sendUpdate: tweetString];
		[self retainActivityIndicatorMiddleOfView];
	}
}

-(void)showLoginScreen{
	UIViewController *controller;
	
	if (_engine) {
		DebugLog(@"engine exists -- returning");
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
	
	if (controller) {
		[self.commentVeiw resignFirstResponder];
		[self presentModalViewController: controller animated: YES];
	}
}

#pragma mark -

/**********************************************************/

- (void)dealloc {
	[theService release];
	[_facebookPermissions release];
    [twitterErrorsCodeDesciption release];
	self.attachedLinkImageView = nil;
	self.facebookMessagePreviewLabel = nil;
	self.titleLabel = nil;
	self.twitterCharCountLabel = nil;
	self.commentVeiw = nil;
	self.entry = nil;
    [super dealloc];
}

@end
