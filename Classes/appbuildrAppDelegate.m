//
//  appbuildrAppDelegate.m
//  appbuildr
//
//  Created by Isaac Mosquera on 1/8/09.
//  Copyright appmakr 2009. All rights reserved.
//

#import "appbuildrAppDelegate.h"
#import "WebpageViewController.h"
#import "GlobalVariables.h"
#import "AppMakrNativeLocation.h"
#import "AppMakrUINavigationBarBackground.h"
#import "Feed.h"
#import "DataStore.h"
#import "SocializeModalViewController.h"
#import "GeoFeedTableViewController.h"
#import "SendMessageViewController.h"
#import "EmailViewController.h"
#import "AdsViewController.h"
#import "NingProfileViewController.h"
#import "ASIHTTPRequest.h"
#import <malloc/malloc.h>
#import <objc/objc-api.h>
#import "PhotoThumbnailController.h"
#import "FeedArchiver.h"
#import "SocializeContainerView.h"
#import "AppMakrAnalytics.h"
#import "SocializeStatsView.h"
#import "SocializeViewController.h"
#import "PointAboutTabBarScrollViewController.h"
#import "ModuleFactory.h"
#import "AuthenticationViewController.h"
#import "FacebookWrapper.h"
#import "GlobalVariables+Twitter.h"
#import "EntryViewController.h"

#import "PlatformTemplate.h"
#import "TabBarTemplateFactory.h"
#import "ScrollMenuTemplateFactory.h"

#define CrittercismAppId @"4eb81f0b3f5b31187e000016"
#define CrittercismKey @"4eb81f0b3f5b31187e000016rgwykcn4"
#define CrittercismSecret @"b9iqe5cfubnygowayazcjh4xdsx3lhm6"

#define FlurryAppId @"L471WWHLVZ1QVZGWEMKH"

static void uncaughtExceptionHandler(NSException *exception) {
}

@interface appbuildrAppDelegate()
-(void)configurateSSZ;
-(void)configurateFlurry;
-(id<PlatformTemplateFactory>) createTemplateFactory:(AppMakrTemplateStyle)type;
-(NSManagedObjectID*) getEntryIdFromUrl: (NSString*)url;

@property (nonatomic, retain) id<PlatformTemplate> appTemplate;
@end

@implementation appbuildrAppDelegate
@synthesize window;
@synthesize webpageController;
@synthesize appTemplate;

BOOL alreadyDidLoad = NO;
BOOL useEncryption;


- (void)dealloc {
    [localDataStore release];
	[DataStore shutdown];
	[window release];
	[splashViewController release];
	[webpageController release];
    [appTemplate release];
	[super dealloc];
}

-(void)loginViewController:(LoginViewController *)controller didAuthenticate:(BOOL)didAuthenticate
{
	[self continueLaunching];
	[controller release];
}

// The callback method after pList update from the webservice either successful or not. 
// Because we have to check the fil in both cases
-(void)globalVarsUpdateCompleted
{
	DebugLog(@"XXXX AppDelegate globalVarsUpdateCompleted XXXX ");
	NSDictionary *global = [GlobalVariables getPlist];
	NSArray *modules = (NSArray *)[global objectForKey:@"modules"];

	BOOL showAppExpired = NO;
	for(int i = 0; i < [modules count]; i++ ) {
		if ([[modules objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {	
			NSDictionary *tabBarView = (NSDictionary*)[modules objectAtIndex:i];
			NSDictionary *fields = [tabBarView objectForKey:@"fields"];
		
			id enabledObject = [fields objectForKey:@"enabled"];
			BOOL enabled = (enabledObject!=nil)?[enabledObject boolValue]:YES;
			if (!enabled && !showAppExpired) 
			{
				showAppExpired = YES;
			}
		}
	}
	
	if (showAppExpired) 
	{
		[self showAppExpiredAlertWithMessage:NSLocalizedString(@"This application has expired.",@"")];
	}
}

-(void)showAppExpiredAlertWithMessage:(NSString*)myMessage{
	
	UIAlertView * expiredView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Expired!",@"") 
														message:myMessage 
														delegate:nil 
												 cancelButtonTitle:NSLocalizedString(@"OK",@"") 
												 otherButtonTitles:nil] autorelease];
	[expiredView show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{

	// try getting the new plist asynchronously to see if any of the tabs have been disabled
	[[GlobalVariables vars] startUpdateWithDelegate:self];
}

-(void)swipeUpTheSocializeView{
    //this all below can be deleted
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL viewerHasBeenEducated = [prefs boolForKey:@"viewerHasBeenEducated"];

// According to Ticket #1338. Design is working on some mockups.
//	if (!viewerHasBeenEducated){
//		[containerView socializeSwipeUpToShowSocializeInfo];
//	}
	
	if (!viewerHasBeenEducated){
		viewerHasBeenEducated = YES;
		[prefs setBool:viewerHasBeenEducated forKey:@"viewerHasBeenEducated"];
		[prefs synchronize];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"##### Incoming URL is: %@", url);
    return [Socialize handleOpenURL:url];
}

-(void)configurateFlurry
{
}

-(NSManagedObjectID*) getEntryIdFromUrl: (NSString*)url
{
    NSArray* entries = [localDataStore retrieveEntitiesForClass:[Entry class] withSortDescriptors:nil andPredicate:[NSPredicate predicateWithFormat:@"url == %@", url]];
    if(entries && [entries count]>0)
        return [(Entry*)[entries objectAtIndex:0] objectID];
    else
        return nil;
}

-(void)configurateSSZ
{        
    NSDictionary* global = [GlobalVariables getPlist];
    NSDictionary * application = (NSDictionary * )[global objectForKey:@"application"];
    NSString * socializeConsumerKey = [application objectForKey:kSocializeConsumerKeyKey];
    socializeConsumerKey = [socializeConsumerKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * socializeConsumerSecret = [application objectForKey:kSocializeConsumerSecretKey];
    socializeConsumerSecret =[socializeConsumerSecret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [Socialize storeConsumerKey:socializeConsumerKey];
    [Socialize storeConsumerSecret:socializeConsumerSecret];
    [Socialize storeFacebookAppId:[FacebookWrapper getFacebookAppId]];
    [Socialize storeAnonymousAllowed:YES];
    
    NSPair* twitterApi = [GlobalVariables twitterApiKeySecret];
    [Socialize storeTwitterConsumerKey:twitterApi.first];
    [Socialize storeTwitterConsumerSecret:twitterApi.second];
    
    [Socialize storeFacebookLocalAppId:[FacebookWrapper getFacebookLocalAppId]];
    
    // Specify a Socialize entity loader block
    [Socialize setEntityLoaderBlock:^(UINavigationController *navigationController, id<SocializeEntity>entity) {
        
        NSManagedObjectID* entryId = [self getEntryIdFromUrl:entity.key];
        if(entryId)
        {
            EntryViewController* entryLoader = [[EntryViewController alloc] initWithEntryID:entryId];

            if (navigationController == nil) {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:entryLoader];
                [self.window.rootViewController presentModalViewController:navigationController animated:YES];
            }
            else {
                [navigationController pushViewController:entryLoader animated:YES];
            }
        }
    }];
    
    [Socialize setCanLoadEntityBlock:^BOOL(id<SocializeEntity> entity) {
        return [self getEntryIdFromUrl:entity.key] != nil;
    }];
    
}

-(void)configuratePushNotifications:(NSDictionary*)launchOptions
{
#if !TARGET_IPHONE_SIMULATOR
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif
    
    // Handle Socialize notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        if ([SZSmartAlertUtils handleNotification:userInfo]) {
            NSLog(@"Socialize handled the notification on app launch.");
        } else {
            NSLog(@"Socialize did not handle the notification on app launch.");
        }
    }
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions  {
    localDataStore = [[DataStore alloc]init];
    [self configurateFlurry];
    [self configurateSSZ];
    [self configuratePushNotifications:launchOptions];
   
    [[AppMakrAnalytics sharedAnalytics] startSession];
    [[AppMakrAnalytics sharedAnalytics] logDownload];
    
    [[AVAudioSession sharedInstance] setDelegate:self];    
	// Allow the app sound to continue to play when the screen is locked.
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
	[[AVAudioSession sharedInstance] setActive:YES error:nil];
	
	[DataStore initializeDataStore];

	NSDictionary* buildDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"build"];

	#pragma mark Start code for App Settings	
	// Get version and build values to be displayed in the Settings App	
	NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSString *buildString = [(NSNumber *)[buildDict objectForKey:@"pk"] stringValue]; 
	NSString *revisionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AMSVNRevision"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *previousVersionString = [defaults objectForKey:@"version_preference"];
    
	// User just updated their app so we should delete previous data
	if(previousVersionString && ![previousVersionString isEqualToString:versionString]) {
		[FeedArchiver removeAllArchivedData];
        NSString *previousRevisionString = [defaults objectForKey:@"revision_preference"];
     	if(previousRevisionString && [previousRevisionString isEqualToString:@"2.24"]) // THIS IS FIX OF 2.24 VERSION WITH HARDCODED API/SECRET. COULD BE REMOVE IN FUTUTE
        {
            [[Socialize sharedSocialize]removeAuthenticationInfo];
        }
	}
	
	[defaults setObject:versionString forKey:@"version_preference"];
	[defaults setObject:buildString forKey:@"build_number_preference"];
	[defaults setObject:revisionString forKey:@"revision_preference"];
        
	// Based on the Reset toggle switch in the Settings App, remove archived data and set the toggleSwitch to OFF state	
	if ([defaults boolForKey:@"reset_preference"]) {
		[FeedArchiver removeAllArchivedData];
		[defaults setBool:NO forKey:@"reset_preference"];	
	}
	
	NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* app = (NSDictionary * )[global objectForKey:@"application"];
	
	BOOL showIntroVideo = [[app objectForKey:@"show_intro_video"] boolValue];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	BOOL showLoginView = [[configuration objectForKey:@"login"]boolValue];
	if (showLoginView) 
	{
		id loginURL = [configuration objectForKey:@"login_url"];
		
		NSAssert((loginURL!=nil 
				  && (loginURL != [NSNull null]) 
				  && ([(NSString *)loginURL length]>0)
				  ),@"Login URL can not be NULL or Empty.");

		LoginViewController *lvc = [[[LoginViewController alloc] init] autorelease];
		lvc.delegate = self;
		lvc.loginURL = (NSString *)loginURL;
        
		[self.window addSubview:lvc.view];
		
		[window makeKeyAndVisible];
	}
	else if(showIntroVideo)
	{
		splashViewController = [[SplashViewController alloc] init];
        
		[self.window addSubview:splashViewController.view];
		[window makeKeyAndVisible];
	}
	else
	{
        [self continueLaunching];
	}
    
    return YES;
}

-(void)continueLaunching
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO];

	NSDictionary* global = [GlobalVariables getPlist];

	//this 'if' statement is here so that we dont load the same view twice when using geo rss
	if( alreadyDidLoad ) {
		return;
	} else {
		alreadyDidLoad = YES;
	}
    
    NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];	
    NSArray* modules = (NSArray *)[global objectForKey:@"modules"];

    id<PlatformTemplateFactory> factory = [self createTemplateFactory:[GlobalVariables templateType]];
       
    self.appTemplate = [factory createTemlateWithConfiguration:configuration modules:modules];
    
    self.window.rootViewController = self.appTemplate.rootViewController;
    
	if ([GlobalVariables hasGeoRssTabIn:modules]) {
        AppMakrNativeLocation* loc = [AppMakrNativeLocation sharedInstance];
        [loc start];
    }

	WebpageViewController* newWebpageController = [[WebpageViewController alloc] init];
	newWebpageController.view.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
	self.webpageController = newWebpageController;
	[newWebpageController release];
	
	[window makeKeyAndVisible];
}

- (void)configurateUrbanairshipNotifications:(NSData *)devToken {
    NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* application = (NSDictionary * )[global objectForKey:@"application"];
	
	// Format the devoce token to read hexadecimal characters
	NSString *deviceToken = [[[[devToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	NSString *UAServer = @"https://go.urbanairship.com";
	NSString *urlString = [NSString stringWithFormat:@"%@%@%@/", UAServer, @"/api/device_tokens/", deviceToken];
	NSURL *url = [NSURL URLWithString:  urlString];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.requestMethod = @"PUT";
	request.username = [application objectForKey:@"urbanairship_app_key"];
	request.password = [application objectForKey:@"urbanairship_app_secret"];
	
	[request setDelegate:self];
	[request setDidFinishSelector: @selector(successMethod:)];
	[request setDidFailSelector: @selector(requestWentWrong:)];
	[queue addOperation:request];
	
	NSString * device_token = [NSString stringWithFormat:@"Device Token: %@", deviceToken];
	[[NSUserDefaults standardUserDefaults]setValue:device_token forKey:@"device_token"];
    
    DebugLog(@"device token = %@", deviceToken);	
}

// Delegation methods 

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	//TODO check if we able to create such request
    NSDictionary* applicationDict = (NSDictionary * )[[GlobalVariables getPlist] objectForKey:@"application"];
    if(applicationDict && [applicationDict objectForKey:@"urbanairship_app_key"] && [applicationDict objectForKey:@"urbanairship_app_secret"] ) 
    {
        [self configurateUrbanairshipNotifications:devToken];
	}

#if !DEBUG
    if([GlobalVariables socializeEnable])
        [SZSmartAlertUtils registerDeviceToken:devToken];
#endif
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    DebugLog(@"Error in registration. Error: %@", err);
}

- (void)retainActivityIndicator {
	_loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	CGRect myFrame = self.window.frame;
	CGRect indFrame = _loadingIndicatorView.frame;
	myFrame.origin.x += (myFrame.size.width - indFrame.size.width) * 0.5f;
	myFrame.origin.y = 210;// 
	myFrame.size = indFrame.size;
	_loadingIndicatorView.frame = myFrame;
	
	[self.window addSubview:_loadingIndicatorView];
	[_loadingIndicatorView startAnimating];
}

- (void)releaseActivityIndicator
{
	if (_loadingIndicatorView != nil){
		[_loadingIndicatorView stopAnimating];
		[_loadingIndicatorView removeFromSuperview];
		[_loadingIndicatorView release];
		_loadingIndicatorView = nil;
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	DebugLog(@"remote notification: %@",[userInfo description]);
    
    // Handle Socialize notification at foreground
    if ([SZSmartAlertUtils handleNotification:userInfo]) {
        NSLog(@"Socialize handled the notification on foreground");
        return;
    }
    
	NSString* message =  [[userInfo objectForKey: @"aps"] objectForKey: @"alert"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remote Notification" message:message delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if([self.appTemplate respondsToSelector:@selector(OnShutdownAction)])
        [self.appTemplate OnShutdownAction];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[AppMakrAnalytics sharedAnalytics] startSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	/*
	 Use this method to release shared resources, save user data, invalidate timers, 
	 and store enough application state information to restore your application to its
	 current state in case it is terminated later.
	 If your application supports background execution, called instead of applicationWillTerminate: 
	 when the user quits.
	*/
    [[AppMakrAnalytics sharedAnalytics] suspendSession];
    
    if([self.appTemplate respondsToSelector:@selector(OnShutdownAction)])
        [self.appTemplate OnShutdownAction];
}

-(id<PlatformTemplateFactory>) createTemplateFactory:(AppMakrTemplateStyle)type
{
    id<PlatformTemplateFactory> template = nil;
    switch (type) {
        case AppMakrTabbarTemplate:
            template = [[TabBarTemplateFactory alloc] init];
            break;
        case AppMakrScrollTemplate:
            template = [[ScrollMenuTemplateFactory alloc] init];
            break;
        default:
            break;
    }
    return [template autorelease];
}

@end
