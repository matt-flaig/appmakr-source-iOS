/*
 * StreamThumbnailController.m
 * appbuildr
 *
 * Created on 7/25/12.
 * 
 * Copyright (c) 2012 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "StreamThumbnailController.h"
#import "Reachability.h"
#import "FeedParser.h"
#import "FeedArchiver.h"
#import "FeedObjects.h"
#import "RefreshTableHeaderView.h"
#import "GlobalVariables.h"
#import "Entry.h"
#import "AdsViewController.h"
#import "ModuleFactory.h"
#import "CustomNavigationBar.h"
#import "NSString+url.h"

static const int IMAGE_WIDTH = 70;
static const int IMAGE_HEIGHT = 70;
static const int IMAGE_PADDING = 8;
static const float IMAGES_PER_ROW_PORTRAIT = 4.0f;
static const float IMAGES_PER_ROW_LANDSCAPE = 6.0f;

@interface StreamThumbnailController ()
- (void)initIndicatorWithFrame :(CGRect) frame addToView:(UIView*) myView;
- (void)releaseActivityIndicator;
- (void)refreshHeader;
- (void)loadFeed;
@property(nonatomic, retain) id<AdsController> adManager;
@property(nonatomic, assign) id<StreamThumbnailControllerDelegate> streamDelegate;
@end

@implementation StreamThumbnailController
@synthesize theFeedService;
@synthesize streamFeed;
@synthesize adManager;
@synthesize streamFeedURLString;
@synthesize feedKey;
@synthesize streamDelegate = _streamDelegate;

- (void)dealloc 
{
	[theFeedService release];
	[streamFeed release];
	[streamScrollView release];
	[refreshHeaderView release];
	[feedKey release];
    self.adManager = nil;
    self.streamDelegate = nil;
    
	[super dealloc];	
}

- (void)applyFeedUrl:(NSString *)photoFeedURL title:(NSString *)aTabTitle {
    self.streamFeedURLString = [photoFeedURL correctUrlEncodedString];
    self.title = self.headerImage ? nil : aTabTitle;
    self.feedKey = aTabTitle;
    
    feedIsLoaded = FALSE;
    isLoading = FALSE;
    self.streamFeed = nil;
}

-(id)initWithFeedURL:(NSString *) streamFeedURL title:(NSString *)aTabTitle delegate: (id<StreamThumbnailControllerDelegate>)delegate{
	if( (self = [super initWithNibName:nil bundle:nil]) ) {
        self.streamFeedURLString = streamFeedURL;
		self.feedKey = aTabTitle;
        self.title = aTabTitle;
        self.streamDelegate = delegate;
    }
	return self;
}

-(void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:YES];
	
	FeedService *myFeedService = [[FeedService alloc] init];
	myFeedService.delegate = self;
	self.theFeedService = myFeedService;
	[myFeedService release];
	DebugLog(@"view will appear");
	[self loadFeed];
	
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
    
	if(self.headerImage)
		[bar setBackgroundWith:self.headerImage];
	else
        [bar clearBackground];
	
	[self.navigationController.navigationBar setTranslucent:NO];
    
    
	self.view.backgroundColor = [UIColor blackColor];	
   	streamScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	DebugLog(@" the retain is %i at this point", [theFeedService retainCount]);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];          
    self.adManager = [AdsViewController createFromGlobalConfiguratinWithTitle:self.title delegate:self];
}

-(void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	DebugLog(@"view will disappear and going to cancel all operations");
	DebugLog(@"view will disappear and going to nil out the feed service");
    
	[self releaseActivityIndicator];
	[self.theFeedService cancelAllFetchRequests];
	self.theFeedService.delegate = nil;
	self.streamFeed = nil;
	self.theFeedService = nil;
    
    self.adManager.delegate = nil;
    if([self.adManager respondsToSelector:@selector(stopLoad)])
        [self.adManager stopLoad];
    [self.adManager.view removeFromSuperview];
    self.adManager = nil;
}
- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.streamFeed = nil;
	self.theFeedService = nil;	
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
    
    [self applyFeedUrl:self.streamFeedURLString title:self.feedKey];
    
	streamScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	streamScrollView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
	streamScrollView.autoresizesSubviews = YES;
    
	refreshHeaderView = [[RefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -30.0f, 320, 30.0)];
	[streamScrollView addSubview: refreshHeaderView];
	[self.view addSubview:streamScrollView];
    
    if([GlobalVariables templateType] == AppMakrScrollTemplate)
    {           
        self.navigationItem.leftBarButtonItem = [self createBackToMainMenuBtnItem];
    }
}


-(void)displayThumbnails {	
    if(!streamFeed && ![streamFeed.entries count])
        return;
    
	int imagesPerRow = IMAGES_PER_ROW_PORTRAIT;
	if( self.interfaceOrientation != UIInterfaceOrientationPortrait ) {
		imagesPerRow = IMAGES_PER_ROW_LANDSCAPE;
		self.navigationController.navigationBar.hidden = YES;
	} else {
		self.navigationController.navigationBar.hidden = NO;
	}
    
	NSInteger max_rows = ceil( (float)[streamFeed.entries count]/imagesPerRow );
    int contentHeight = max_rows * (IMAGE_HEIGHT + (2*IMAGE_PADDING) );
	contentHeight = contentHeight < 440 ? 440 : contentHeight;
	streamScrollView.contentSize = CGSizeMake(320, contentHeight);
	streamScrollView.backgroundColor = [UIColor blackColor];
	streamScrollView.showsVerticalScrollIndicator = NO;
	streamScrollView.delegate = self;
	streamScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if([self.streamDelegate respondsToSelector:@selector(startShowStream:)] ) 
        [self.streamDelegate startShowStream: self];

	int index = 0;
	for(NSInteger row=0; row < max_rows ; row++) {
		for(NSInteger column=0; column < imagesPerRow && index < [streamFeed.entries count]; column++) {
			
			int x = (IMAGE_WIDTH * column) + (IMAGE_PADDING * (column+1));
			int y = (IMAGE_HEIGHT * row ) + (IMAGE_PADDING * (row+1));
			
			CGRect gridFrame = CGRectMake(x, y, IMAGE_WIDTH, IMAGE_HEIGHT);
			UIView* grid = [self.streamDelegate getStreamElementForIndex: index withFrame:gridFrame];
            [streamScrollView addSubview:grid];
			index++;
		}
	}
    if([self.streamDelegate respondsToSelector:@selector(comleteShowStream:)] ) 
        [self.streamDelegate comleteShowStream: self];
}

- (void)initIndicatorWithFrame:(CGRect) frame addToView:(UIView*) myView {
	if (loadingIndicatorView == nil){
        loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect myFrame = frame;
        CGRect indFrame = loadingIndicatorView.frame;
        myFrame.origin.x += (frame.size.width - indFrame.size.width) * 0.5f;
        myFrame.origin.y = 110;// 
        myFrame.size = indFrame.size;
        loadingIndicatorView.frame = myFrame;
        
        [myView addSubview:loadingIndicatorView];
        [loadingIndicatorView startAnimating];
    }
}


- (void)releaseActivityIndicator
{
	if (loadingIndicatorView != nil){
		[loadingIndicatorView stopAnimating];
		[loadingIndicatorView removeFromSuperview];
		[loadingIndicatorView release];
		loadingIndicatorView = nil;
	}
}

- (void)refreshHeader
{
	//the following will reset the refresh header for the next time it gets pulled.
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[streamScrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[refreshHeaderView setStatus:kPullToReloadStatus];
	[refreshHeaderView animateActivityView:NO];
	[UIView commitAnimations];
    self.view.userInteractionEnabled = YES;
	
}

#pragma mark feed service callabcks
-(void) feedService:(FeedService *)feedService didStartFetchingFeedForUrl:(NSURL *)feedUrl
{
    
	DebugLog(@"feed parsing has begun!");
	isLoading = YES;
}

-(void) feedService:(FeedService *)feedService didFetchFeed:(Feed *)feed
{
	[self refreshHeader];
	[self releaseActivityIndicator];
	isLoading = NO;
	
	DebugLog(@"did fetchFeed called");
	self.streamFeed = feed;
	feedIsLoaded = TRUE;
	[self displayThumbnails];
}

-(void) feedService:(FeedService *)feedService didFailFetchingFeedWithError:(NSError *)error
{
	DebugLog(@"Fetch feed failed->%@",[error localizedDescription]);
	[self refreshHeader];
	[self releaseActivityIndicator];
	isLoading = NO;
	
}

//TODO:: add oweride in child class and remove from here
-(void) feedServiceDidFinishFetchingFeed:(FeedService *)feedService
{	
}

-(void) feedService:(FeedService *)feedService didFinishFetchingThumbnailForEntry:(Entry *)entry
{
}

#pragma mark ==

#pragma mark feed parser callabcks

-(void)loadFeed 
{  
   	self.streamFeed = nil;
    
    if( !feedIsLoaded && [NetworkCheck hasInternet] ) {
		[self initIndicatorWithFrame:self.view.frame addToView:self.view];
        self.view.userInteractionEnabled = NO;
       	[self.theFeedService cancelAllFetchRequests];
        NSURL * feedURL = [NSURL URLWithString:streamFeedURLString];
		[theFeedService fetchFeedFromUrl:feedURL saveWithKeyValue:feedKey AndType:self.moduleType];
	}
    else
    {
		self.streamFeed = [theFeedService fetchFeedFromCacheWithKey:feedKey];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	//special case if there is no network connection
	if (![NetworkCheck hasInternet]) {
		[refreshHeaderView setStatus:kNoConnectionStatus];
	} else if (streamScrollView.contentOffset.y > -65.0f && streamScrollView.contentOffset.y < 0.0f && !isLoading) {
		[refreshHeaderView setStatus:kPullToReloadStatus];
	}
	
	if (refreshHeaderView && refreshHeaderView.isFlipped && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !isLoading) {
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//only refresh if the user has dragged the header up far enough
	if (scrollView.contentOffset.y <= - 65.0f && [NetworkCheck hasInternet] && !isLoading) 
	{
		feedIsLoaded = FALSE;
		[self loadFeed];
		[refreshHeaderView animateActivityView:YES];	
		
		//the followinglock the header in place while the feed is loading
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		streamScrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];	
	} 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	DebugLog(@"\n\n\n\n Photo Album VC - MEMORY WARNING !!!!  - NOT calling RESET  \n\n\n");
}

#pragma mark rotation
 
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma  mark Ads

-(void)adReceived
{  
    if(self.adManager.view.superview == nil)
    {
        CGRect newScrollFrame = streamScrollView.frame;
        newScrollFrame.size.height -= 50;
        streamScrollView.frame = newScrollFrame;
        
        CGRect adFrame = CGRectMake(0, streamScrollView.frame.size.height, streamScrollView.frame.size.width, 50);
        self.adManager.view.frame = adFrame;
        [self.view addSubview:self.adManager.view];
    }
}

#pragma track and apply configs

-(BOOL) wasConfigurationChanged:(NSDictionary*) configs
{
    DebugLog(@"%@", self.streamFeedURLString);
    DebugLog(@"%@", [ModuleFactory feedUrl:configs]);
    return !([self.streamFeedURLString isEqualToString:[ModuleFactory feedUrl:configs]] && [self.feedKey isEqualToString:[ModuleFactory tabTitle:configs]]);
}

-(void) OnConfigUpdate: (NSNotification*) notification
{
    NSDictionary* configs = [GlobalVariables configsForModulePath:self.modulePath];
    if([self wasConfigurationChanged: configs])
    {
        [self applyFeedUrl:[ModuleFactory feedUrl:configs] title:[ModuleFactory tabTitle:configs]];
        [self loadFeed];
       	[self displayThumbnails];
    }
}

@end

