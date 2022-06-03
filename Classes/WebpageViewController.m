//
//  WebpageController.m
//  appbuildr
//
//  Created by PointAboutAdmin on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "WebpageViewController.h"
#import "appbuildrAppDelegate.h"
#import "GlobalVariables.h"
#import "AppMakrUINavigationBarBackground.h"
#import "FeedArchiver.h"
#import "SocializeModalViewController.h"
#import "CommentViewController.h"
#import "AppMakrShareActionSheet.h"
#import "AdsViewController.h"
#import <Socialize/Socialize.h>
#import "UIActionSheet+Utils.h"
#import "UITapGestureRecognizer+SingleTap.h"
#import "CustomNavigationBar.h"
#import "FullscreenEvents.h"

const float toolbarHeight = 44.0f;

@interface WebpageViewController()
    @property(nonatomic, retain) id<AdsController> adManager;
    @property(nonatomic, retain) SZActionBar* sszActionBar;
    @property(nonatomic, retain) UITapGestureRecognizer *singleTap;

    -(void)catchTapAction: (NSNotification *)notification;
@end

@implementation WebpageViewController
@synthesize entryURL;
@synthesize webpageView;
@synthesize reloadButton;
@synthesize progressView;
@synthesize parentController;
@synthesize entry;
@synthesize adManager = _adManager;
@synthesize sszActionBar = _sszActionBar;
@synthesize singleTap = _singleTap;

-(void)setEntry:(Entry *)newEntry
{
    if(entry != newEntry)
    {
        [entry.managedObjectContext release];
        [entry release];
        entry = [newEntry retain];
        [entry.managedObjectContext retain];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	

	// create a uiwebview which is 320x460~ and add it to the uiview by sending the message [addSubview: ];
	webpageView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-toolbarHeight)];
	webpageView.delegate = self;
	webpageView.scalesPageToFit = YES; 
	webpageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight);
	    
	// add a toolbar to the new uiview

	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-toolbarHeight, 320, toolbarHeight)];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	NSDictionary *configDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( configDict ) {
		CGFloat bgRed = [(NSNumber *)[configDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[configDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[configDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		UIColor *headerBgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
		toolbar.tintColor = headerBgColor;
	}
	
	NSNumber * hideWeblinkButtonNum = (NSNumber *)[[[GlobalVariables getPlist] objectForKey:@"configuration"]
                                                                               objectForKey:@"hide_weblink_button"];
	BOOL hideWeblinkButton = YES;
	if( hideWeblinkButtonNum ) {
		hideWeblinkButton = [hideWeblinkButtonNum boolValue];
	}
	
	if (!hideWeblinkButton && ![GlobalVariables socializeEnable]) {
		UIBarButtonItem *gotoLinkButton = 
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped)];
		
		self.navigationItem.rightBarButtonItem = gotoLinkButton;	
		
		[gotoLinkButton release];
	}
	
	UIBarButtonItem *myReloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadpageView)];
	self.reloadButton = myReloadButton;
	[myReloadButton release];
	UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *fixedSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpaceButton.width = 20;
	
	backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backpageView)];
	backButton.enabled = NO;
	
	forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardpageView)];
	[forwardButton setWidth:50];
	forwardButton.enabled = NO;
	
	safariButton = [[UIBarButtonItem alloc] initWithTitle:@"Safari" style:UIBarButtonItemStyleBordered target:self action:@selector(launchSafari)];
	
	//[toolbar setItems:[NSArray arrayWithObjects: backButton,flexibleSpaceButton, forwardButton, flexibleSpaceButton, safariButton, flexibleSpaceButton, reloadButton,nil] animated:YES];
	[toolbar setItems:[NSArray arrayWithObjects: backButton,fixedSpaceButton, forwardButton, fixedSpaceButton, safariButton, flexibleSpaceButton, reloadButton,nil] animated:YES];
	toolbar.barStyle = UIBarStyleDefault;
	toolBarItemCount = [toolbar.items count];
	self.hidesBottomBarWhenPushed = TRUE;
	
	// add the subviews
	[self.view addSubview: webpageView];
	[self.view addSubview: toolbar];
	
	[flexibleSpaceButton release];
	[fixedSpaceButton release];
	[backButton release];
	[forwardButton release];
	[safariButton release];
    
    self.singleTap = [UITapGestureRecognizer createSingleTapRecognizerWithTarget:self action:@selector(catchTapAction:)];
    [self.webpageView addGestureRecognizer:self.singleTap];
}

-(void) catchTapAction:(NSNotification *)notification
{
    if(self.sszActionBar.superview)
    {
        [UIView animateWithDuration:0.5 animations:
             ^(void)//show/hide action bar
             {
                 CGFloat alpha = self.sszActionBar.alpha == 0 ? 1:0;
                 self.sszActionBar.alpha = alpha;
             }
         ];
    }
}

- (void)addSszActionBar {
    [self.sszActionBar removeFromSuperview];
    if (self.entryURL && [GlobalVariables socializeEnable]){
        self.sszActionBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:[SZEntity entityWithKey:self.entryURL name:self.entry.title != nil ? self.entry.title: @""] viewController:self];
        [self.view addSubview:self.sszActionBar];
    }
}

- (void)showWebPageView {
    [self addSszActionBar];
    
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.entryURL]];
	[webpageView loadRequest:request];
	
	backButton.enabled = NO;
	forwardButton.enabled = NO;
	
	[self.navigationController.navigationBar setHidden:NO];
	
	[request release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{	 
	DebugLog(@"################## the url is %@", request);
	return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:entryURL]];
	else if(buttonIndex == 1)
		[self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	[self.progressView startAnimating];
	
// remove the reload button which is the last object of the array	
	NSMutableArray *toolBarArray =[NSMutableArray arrayWithArray:toolbar.items];
	if (toolBarArray.count >= toolBarItemCount) {
		[toolBarArray removeLastObject];
		toolbar.items = toolBarArray;
	}
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self checkForMovement];
	// After page is loaded stop animation
	[progressView stopAnimating];
	
// add the reload button at the end of the array	
	NSMutableArray *toolBarArray =[NSMutableArray arrayWithArray:toolbar.items];
	if (toolBarArray.count < toolBarItemCount) {
		[toolBarArray addObject:reloadButton];
		toolbar.items = toolBarArray;
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if([error code] == NSURLErrorCancelled) return;
    
	DebugLog(@"error is: %@", [error description]);
    [webpageView loadHTMLString:@"<html></html>" baseURL:nil];
}

- (void)actionButtonTapped {
    
  	toModalView = YES;
    AppMakrShareActionSheet *actionSheet = [AppMakrShareActionSheet actionSheetForEntry:entry configurationBlock: ^(AppMakrShareActionSheet* actionSheet)
                                            {
                                                NSDictionary *configDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];                                                
                                                actionSheet.facebookShare = [[configDict objectForKey:@"share_facebook"] boolValue];
                                                actionSheet.twitterShare = [[configDict objectForKey:@"share_twitter"] boolValue];
                                                actionSheet.mailShare = [[configDict objectForKey:@"share_email"] boolValue]; 
                                                actionSheet.appMakrPublish = [[[GlobalVariables getPlist] objectForKey:@"is_appmakr_publish"] boolValue];
                                                
                                                actionSheet.parentController = self;
                                            }];
    
	// Display the action sheet
	[actionSheet showInView:self.view.window];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self resize];
}

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations.
	return [MPMoviePlayerController isOnFullScreenPlayback] || interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated {
    // set up navigation delegate
    self.navigationController.delegate = self;
    
	toModalView = YES;
	[progressView setHidden:NO];
	
	if( !progressView ) {
		UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] init];
		self.progressView = indicatorView;
		[self.progressView startAnimating];
		[toolbar addSubview:self.progressView];
		//DebugLog(@"self. nav bar %@", self.navigationController.navigationBar);
		//[webpageView addSubview:self.progressView];
		[indicatorView release];
		self.progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	}
	
    self.webpageView.frame =  CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height-toolbarHeight);
	[self resize];

    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
    {
        [((CustomNavigationBar*)self.navigationController.navigationBar) clearBackground];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.adManager = [AdsViewController createFromGlobalConfiguratinWithTitle:@"" delegate:self];
}


- (void)viewDidDisappear:(BOOL)animated {
    if(!toModalView)
		[webpageView loadHTMLString:@"<html></html>" baseURL:nil];

    self.adManager.delegate = nil;
    if([self.adManager respondsToSelector:@selector(stopLoad)])
        [self.adManager stopLoad];
    [self.adManager.view removeFromSuperview];
    self.adManager = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
	[progressView removeFromSuperview];
	self.progressView = nil;
}

- (void)checkForMovement {
	if (webpageView.canGoBack) {
		backButton.enabled = YES;
	} else {
		backButton.enabled = NO;
	}
	
	if (webpageView.canGoForward) {
		forwardButton.enabled = YES;
	} else {
		forwardButton.enabled = NO;
	}
}

- (void)reloadpageView {
	//DebugLog(@"reload the pageview");
	[self.webpageView reload];
}

- (void)emailAction {
	//DebugLog(@"e-mailing action");
	//	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:imosquer@gmail.com?subject=testMail&body=its test mail."]];
	
	NSURL *url = [NSURL URLWithString:@"mailto:?subject=subject&body=body"];
	[[UIApplication sharedApplication] openURL:url];
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
}
- (IBAction)backpageView {
	//DebugLog(@"go to previous pageview");
	[self.webpageView goBack];
}

- (IBAction)forwardpageView {
	//DebugLog(@"go to next pageview");
	[self.webpageView goForward];
}

- (void) launchSafari{
	//DebugLog(@"safari");
	NSURL *url = [NSURL URLWithString:self.entryURL];
	[[UIApplication sharedApplication] openURL:url];
}

- (void)closeView {
	//DebugLog(@"close the pageview");
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	//self.view.frame = CGRectMake(0, 485, 320, 480);
	[UIView commitAnimations];
	//DebugLog(@"closed the pageview successfully");
}

-(void)resize
{

}

-(void) presentAds
{
    if(self.adManager.view.superview == nil)
    {
        CGRect newWebFrame = self.webpageView.frame;
        newWebFrame.size.height -= 49;
        self.webpageView.frame = newWebFrame;
        
        CGRect adFrame = CGRectMake(0, self.webpageView.frame.size.height, self.webpageView.frame.size.width, 49);
        self.adManager.view.frame = adFrame;
        [self.view addSubview:self.adManager.view];
    }
}

-(void)adReceived
{  
    [self presentAds];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[reloadButton release];
	[toolbar release];
	[webpageView release];
	[progressView release];
    self.entry = nil;
    self.adManager = nil;
    self.sszActionBar = nil;
    self.singleTap = nil;
    [super dealloc];
}

#pragma mark -- UINavigationController delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(viewController!=self)//go to other controller.
        toModalView = NO;
}
#pragma mark - Tap Gesture Delegate 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
