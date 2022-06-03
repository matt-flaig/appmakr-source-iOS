//
//  AuthorizeViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 5/17/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AuthorizeViewController.h"
#import "AppMakrUINavigationBarBackground.h"
#import "UIButton+Socialize.h"
#import "FacebookWrapper.h"
#import "CommentViewController.h"//*
#import "GlobalVariables.h"

@interface  AuthorizeViewController(private)
-(AuthorizeTableViewCell *)getAuthorizeTableViewCell;
-(AuthorizeInfoTableViewCell*)getAuthorizeInfoTableViewCell;
@end

@implementation AuthorizeViewController

@synthesize tableView;
@synthesize socialize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<AuthorizeViewDelegate>)mydelegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        delegate = mydelegate;
        boolErrorStatus = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:50/255.0f green:58/255.0f blue:67/255.0f alpha:1.0];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithRed:25/255.0f green:31/255.0f blue:37/255.0f alpha:1.0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // return 1;
    NSInteger noOfRows = 0;
	switch (section) 
	{
		case 0:
            noOfRows = 1;
            break;
        case 1:
            noOfRows = 1;
            break;
    }
    return noOfRows;
}

-(AuthorizeInfoTableViewCell *)getAuthorizeInfoTableViewCell
{
	static NSString *authorizeInfoTableViewCellId = @"authorize_info_cell";
	AuthorizeInfoTableViewCell *cell =(AuthorizeInfoTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:authorizeInfoTableViewCellId];
    
	if (cell == nil) 
	{
		NSArray *topLevelViews = [[NSBundle mainBundle] loadNibNamed:@"AuthorizeInfoTableViewCell" owner:self options:nil];
		for (id topLevelView in topLevelViews) {
			if ([topLevelView isKindOfClass:[AuthorizeInfoTableViewCell class]] ) {
                cell = topLevelView;
            }
        }
	}
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(AuthorizeTableViewCell *)getAuthorizeTableViewCell
{
	static NSString *profileCellIdentifier = @"authorize_cell";

	AuthorizeTableViewCell *cell =(AuthorizeTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
    
	if (cell == nil) 
	{
		NSArray *topLevelViews = [[NSBundle mainBundle] loadNibNamed:@"AuthorizeTableViewCell" owner:self options:nil];
		for (id topLevelView in topLevelViews) {
			if ([topLevelView isKindOfClass:[AuthorizeTableViewCell class]] ) {
                cell = topLevelView;
            }
        }
	}
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(indexPath.section == 0){
/*
        NSArray* permissions = [[NSArray arrayWithObjects:@"read_stream", @"offline_access", nil] retain];
        [[FacebookWrapper facebook] authorize:permissions delegate:self]; 
*/

        if (socialize != nil) {
            [socialize removeAuthenticationInfo];
        }
        else {
            socialize = [[Socialize alloc] initWithDelegate:self];
        }
        
        NSDictionary* global = [GlobalVariables getPlist];
        NSDictionary * application = (NSDictionary * )[global objectForKey:@"application"];
        NSString * socializeConsumerKey = [application objectForKey:kSocializeConsumerKeyKey];
        socializeConsumerKey = [socializeConsumerKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString * socializeConsumerSecret = [application objectForKey:kSocializeConsumerSecretKey];
        socializeConsumerSecret =[socializeConsumerSecret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        

//        [socialize authenticateWithApiKey:socializeConsumerKey
//                                apiSecret:socializeConsumerSecret
//                          thirdPartyAppId:[FacebookWrapper getFacebookAppId]
//                           thirdPartyName:FacebookAuth];

    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    AuthorizeTableViewCell* authCell = nil;
    AuthorizeInfoTableViewCell* infoCell = nil;
	
	switch (indexPath.section) 
	{
		case 0:
			authCell = [self getAuthorizeTableViewCell];
			authCell.backgroundColor = [UIColor colorWithRed:61/255.0f green:70/255.0f blue:76/255.0f alpha:1.0] ;
            
            if (indexPath.row == 0) {
                authCell.cellIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-authorize-facebook-disabled-icon.png"];
                authCell.cellLabel.text = @"facebook";
            }
            else if (indexPath.row == 1){
                authCell.cellIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-authorize-twitter-disabled-icon.png"];
                authCell.cellLabel.text = @"twitter";
            }
            
            authCell.cellAccessoryIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-call-out-arrow.png"];
            cell = authCell;
			break;
			
		case 1:
		default:
			infoCell = [self getAuthorizeInfoTableViewCell];
			infoCell.backgroundColor = [UIColor colorWithRed:41/255.0f green:48/255.0f blue:54/255.0f alpha:1.0];
            infoCell.cellIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-authorize-user-icon.png"];
            infoCell.cellLabel.text = @"You are currently anonymous.";
            infoCell.cellSubLabel.text = @"Authenticate with a service above";
            cell = infoCell;
			break;
	}
    
	return cell;
}


- (void)fbDidLogin {
	//get the current user's name and setup the staticUpdateLabel in the delegate method
    [[NSUserDefaults standardUserDefaults] setObject:[FacebookWrapper facebook].accessToken forKey:@"AccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:[FacebookWrapper facebook].expirationDate forKey:@"ExpirationDate"];
    
    [[FacebookWrapper facebook] requestWithGraphPath:@"me" andDelegate:self];
    [self retainActivityIndicatorMiddleOfView];

}


-(void)fbDidNotLogin:(BOOL)cancelled {
    [delegate authorizationCompleted:NO]; 
    
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
 * Called when an error prevents the Facebook API request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	DebugLog(@"request didFailWithError %@",[error localizedDescription]);
	
	[self releaseActivityIndicatorMiddleOfView];
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

// FBRequestDelegate
- (void)request:(FBRequest*)request didLoad:(id)result {
	
	//user query
    //was anything returned?
    if ([result count] > 0) {
        
        //get the user from the query
        if ([result isKindOfClass:[NSDictionary class]]){
            DebugLog(@"result class info %@ ", result );
            NSDictionary *user = result;
        
            //check that the name is not null
            if (![[user objectForKey:@"id"] isKindOfClass:[NSNull class]]) {
                
                theService = [[AppMakrSocializeService alloc] init];
                theService.delegate = self;
                _facebookUsername = [user objectForKey:@"id"];
                [theService authenticateWithThirdPartyCreds:_facebookUsername accessToken:[FacebookWrapper facebook].accessToken];
            }
        }
    }
	else {
		DebugLog(@" Printing out the requests name %@ ", [request.params valueForKey:@"name"]);
		DebugLog(@" Printing out the request %@ ", request);
		[self releaseActivityIndicatorMiddleOfView];
	}
}
#pragma mark -

- (NSObject *)checkErrorStatusCodeTestExecution {
    //NSLog(@"checkErrorStatusCodeTestExecution");
    return (boolErrorStatus?[NSString stringWithString:@"success"]:nil);
}

- (void)errorStatusCodeTest {
    boolErrorStatus = YES;
}

#pragma mark appmakr socialize service callbacks
-(void) socializeService:(AppMakrSocializeService *)mysocializeService didAuthenticateSuccessfully:(BOOL)successYesOrNO error:(NSError *)error{
    [self releaseActivityIndicatorMiddleOfView];
    //TESTING
    if (error != nil) {
        if (error.code != 200) {
            [self errorStatusCodeTest];
            /*
            //Commented because of problems when unit testing
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Problem occurred with authentication on server. Please, check your credentials first, if authentication fails again - report the problem." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            */
        }
        else {
            //checking for 200 though it would never happen according to calls of this method
            if (successYesOrNO) {
                [delegate authorizationCompleted:YES];
            } 
        }
    }
    else {
        if (successYesOrNO) {
            [delegate authorizationCompleted:YES];
        }
    }
    //
}
#pragma mark -

//SocializeServiceDelegate
-(void)didAuthenticate {
    NSLog(@"didAuthenticate");
}

-(void)didAuthenticate:(id<SocializeUser>)user{
    [self retainActivityIndicatorMiddleOfView];
//    
//    theService = [[AppMakrSocializeService alloc] init];
//    theService.delegate = self;
//    NSString *userIdForBETAAuth = [[user userIdForThirdPartyAuth:FacebookAuth] stringValue];
//    NSString *accessTokenForBETAAuth = [socialize.authService receiveFacebookAuthToken];
//    
//    //TEST
//    [FacebookWrapper facebook].accessToken = accessTokenForBETAAuth;
//    [[NSUserDefaults standardUserDefaults] setObject:[FacebookWrapper facebook].accessToken forKey:@"AccessToken"];
//    //
//    
//    [theService authenticateWithThirdPartyCreds:userIdForBETAAuth accessToken:accessTokenForBETAAuth];
}

// if the authentication fails the following method is called
-(void)service:(SocializeService*)service didFail:(NSError*)error{
    NSLog(@"%@", error);
}

@end
