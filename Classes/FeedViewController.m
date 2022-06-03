//
//  FeedController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/1/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "FeedViewController.h"
#import "RefreshTableHeaderView.h"
#import "appbuildrAppDelegate.h"
#import "NetworkCheck.h"
#import "FeedParser.h"
#import "FeedArchiver.h"
#import "ModuleFactory.h"
#import "GTMNSString+HTML.h"
#import "CustomNavigationBar.h"
#import "NSString+url.h"

@implementation FeedViewController

@synthesize feed;
@synthesize _internalScrollView;
@synthesize archivePath;
@synthesize rssFeedUrl;
@synthesize adManager;
@synthesize feedKey;
@synthesize showTopImage =_showTopImage;

@synthesize theFeedService;

-(void)dealloc {
	[theFeedService release], theFeedService = nil;
	[rssFeedUrl release];
	[archivePath release];
	[refreshHeaderView release];
	//[progressBarView release];
	[feedKey release];
	[_internalScrollView release];
	self.adManager = nil;
	[cleanTitle release];
	[super dealloc];
}
 
- (void)applyFeedUrl:(NSString *)feedUrl title:(NSString *)title {
    
    self.rssFeedUrl = [feedUrl correctUrlEncodedString];
    self.title = self.headerImage ? nil : title; 
    self.feedKey = title;
    
    if(cleanTitle)
        [cleanTitle release];
    
    cleanTitle = [[title stringByReplacingOccurrencesOfString:@" " withString:@"_"] retain];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.archivePath = [[documentsDirectory stringByAppendingFormat:@"/feed_archives/%@", title] retain];
	didOnloadRefresh = NO;
}

- (id)initWithFeed:(NSString* ) feedUrl title:(NSString*) title {
	if ((self = [super initWithNibName:nil bundle:nil])) {
		self.rssFeedUrl = feedUrl;
        self.feedKey = title;
        self.title = title;

		_internalScrollView = [[UIScrollView alloc]init];
		reloading = NO;
        self.showTopImage = YES; //set default value
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];	

    [self applyFeedUrl:self.rssFeedUrl title:self.feedKey];
    
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
	self.view.autoresizesSubviews = YES;

    refreshHeaderView = [[RefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
	refreshHeaderView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:0.5];
	
	[self._internalScrollView addSubview:refreshHeaderView];
    
    if([GlobalVariables templateType] == AppMakrScrollTemplate)
    {           
        self.navigationItem.leftBarButtonItem = [self createBackToMainMenuBtnItem];
    }    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
		
	//special case if there is no network connection
	if (![NetworkCheck hasInternet]) {
		[refreshHeaderView setStatus:kNoConnectionStatus];
	} else if (scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
		[refreshHeaderView setStatus:kPullToReloadStatus];
	}
	
	if (checkForRefresh) {		
		if (refreshHeaderView && refreshHeaderView.isFlipped && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !reloading) {
			[refreshHeaderView flipImageAnimated:YES];
			if (refreshHeaderView.currentStatus != kNoConnectionStatus) {
				[refreshHeaderView setStatus:kPullToReloadStatus];
			}
		} else if (refreshHeaderView && !refreshHeaderView.isFlipped && scrollView.contentOffset.y < -65.0f) {
			[refreshHeaderView flipImageAnimated:YES];
			if (refreshHeaderView.currentStatus != kNoConnectionStatus) {
				[refreshHeaderView setStatus:kReleaseToReloadStatus];
			}
		}
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//only refresh if the user has dragged the header up far enough
	if ( scrollView.contentOffset.y <= - 65.0f) {

		if ([NetworkCheck hasInternet] && !reloading) {
			reloading = YES;
			[self refreshEntries];
			[refreshHeaderView animateActivityView:YES];

			//lock the header in place
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2];
			scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			[UIView commitAnimations];	
		}
		else if(![NetworkCheck hasInternet]) {
			[self performSelector:@selector(resetRefreshHeader) withObject:nil afterDelay:1.0];
		}
	} 
}
- (void)refreshEntries 
{
	if ([NetworkCheck hasInternet]) 
	{
		checkForRefresh = NO;
		//progressBarView.feedStarted = NO;
		DebugLog(@"feedUrl = %@", rssFeedUrl);
		[self.theFeedService fetchFeedFromUrl:[NSURL URLWithString:self.rssFeedUrl] saveWithKeyValue:feedKey AndType:self.moduleType];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
	} 
}

		 
#pragma mark refresh header/progress bar
-(void)hideProgressBar {
	reloading = NO;
	checkForRefresh = YES;
	[self resetRefreshHeader];
}

- (void)resetRefreshHeader {
	if (refreshHeaderView) {
		[refreshHeaderView flipImageAnimated:NO];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		[self._internalScrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
		[refreshHeaderView setStatus:kPullToReloadStatus];
		[refreshHeaderView animateActivityView:NO];
		[UIView commitAnimations];	
		
		//only update the last refreshed date if we actually refreshed the data
		if (refreshHeaderView.currentStatus != kNoConnectionStatus) {
			[refreshHeaderView setCurrentDate];
		}
	}
}

#pragma mark -
#pragma mark Millennial Ad View call backs

#pragma mark -
#pragma mark view callbacks
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	self.adManager = [AdsViewController createFromGlobalConfiguratinWithTitle:cleanTitle delegate:self];
}

#pragma mark rotation functions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)loadFeed
{
	self.feed = nil;
    if( !didOnloadRefresh && [NetworkCheck hasInternet] ) {
		reloading = YES;
		[refreshHeaderView animateActivityView:YES];
		self._internalScrollView.contentOffset = CGPointMake(0, -65);
		self._internalScrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		checkForRefresh = NO;
		[self refreshEntries];
	}
    else
    {
        self.feed = [theFeedService fetchFeedFromCacheWithKey:feedKey];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{	
	[super viewWillAppear:animated];
	
	NSDictionary *headerBgDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( headerBgDict ) {
		CGFloat bgRed = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[headerBgDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		UIColor *headerBgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
		self.navigationController.navigationBar.tintColor = headerBgColor;
	}

   	CustomNavigationBar* bar = nil;
    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
        bar = (CustomNavigationBar*)self.navigationController.navigationBar;
    
	if(self.showTopImage && self.headerImage)
		[bar setBackgroundWith:self.headerImage];
	else
        [bar clearBackground];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	[[[self tabBarController] tabBar] setHidden:NO];

	// Load archived data for newly selected tab
	
	AppMakrSocializeService *myFeedService = [[AppMakrSocializeService alloc] init];
	myFeedService.delegate = self;
	
//	if (!myFeedService.userIsAuthenticatedAnonymously) 
//	{
//		[myFeedService authenticate];
//		
//	}
	self.theFeedService = myFeedService;
	[myFeedService release];
		
	[self loadFeed];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	
	[self.theFeedService cancelAllFetchRequests];
	self.feed = nil;
	self.theFeedService.delegate = nil;
	self.theFeedService = nil;	
	
	[self hideProgressBar];
}

-(void) viewDidUnload
{
	self.feed = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.adManager.delegate = nil;
    if([self.adManager respondsToSelector:@selector(stopLoad)])
        [self.adManager stopLoad];
    [self.adManager.view removeFromSuperview];
    self.adManager = nil;
}


#pragma mark -
-(void) presentAds
{
    if(self.adManager.view.superview == nil)
    {
        CGRect newScrollFrame = self._internalScrollView.frame;
        newScrollFrame.size.height -= 49;
        self._internalScrollView.frame = newScrollFrame;
        
        CGRect adFrame = CGRectMake(0, self._internalScrollView.frame.size.height, self._internalScrollView.frame.size.width, 49);
        self.adManager.view.frame = adFrame;
        [self.view addSubview:self.adManager.view];
    }
}

-(void)adReceived
{  
    [self presentAds];
}

#pragma mark FeedServiceDelegate implementation

-(void) feedService:(FeedService *)feedService didStartFetchingFeedForUrl:(NSURL *)feedUrl {
	
	
}

-(void) feedService:(FeedService *)feedService didFetchFeed:(Feed *)aFeed {

	self.feed = aFeed;
	DebugLog(@"Feed Type = %@", self.feed.moduleType);

}

-(void) feedService:(FeedService *)feedService didFailFetchingFeedWithError:(NSError *)error {

	NSLog(@"didFailFetchingFeedWithError: %@", [error description]);
	
	[self hideProgressBar];
}


-(void) feedServiceDidFinishFetchingFeed:(FeedService *)feedService {

	didOnloadRefresh = YES;
	[self hideProgressBar];
}

-(void) feedService:(FeedService *)feedService didFinishFetchingThumbnailForEntry:(Entry *)entry {
	
}

-(void) feedService:(FeedService *)feedService didFetchFullSizedImageForEntry:(Entry *)entry {
	
}

-(void) feedService:(FeedService *)feedService didFailFetchingFullSizedImageWithError:(NSError *)error {
	
}

-(void) feedServiceDidFinishFetchingFullSizedImage:(FeedService *)feedService {
	
}

#pragma trak and apply configs
-(BOOL) wasConfigurationChanged:(NSDictionary*) configs
{
    DebugLog(@"%@", self.rssFeedUrl);
    DebugLog(@"%@", [ModuleFactory feedUrl:configs]);
    return !([self.rssFeedUrl isEqualToString:[ModuleFactory feedUrl:configs]] && [self.feedKey isEqualToString:[ModuleFactory tabTitle:configs]]);
}
-(void) OnConfigUpdate: (NSNotification*) notification
{
    NSDictionary* configs = [GlobalVariables configsForModulePath:self.modulePath];
    if([self wasConfigurationChanged:configs])
    {
        [self applyFeedUrl:[ModuleFactory feedUrl:configs] title:[ModuleFactory tabTitle:configs]];
        [self loadFeed];
    }
}

    
@end
