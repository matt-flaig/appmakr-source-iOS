//
//  DescriptionViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 1/10/09.
//  Copyright 2009 appmakr. All rights reserved.
//
#import <Socialize/Socialize.h>

#import "EntryViewController.h"
#import "appbuildrAppDelegate.h"
#import "WebpageViewController.h"
#import "AppMakrUINavigationBarBackground.h"
#import "GlobalVariables.h"
#import "CustomAdView.h"
#import "FeedObjects.h"
#import "VarietyView.h"
#import "NSString+XMLEntities.h"
#import "FeedArchiver.h"
#import "UIColor-Expanded.h"
#import "LinkUtilities.h"
#import	"MFMailComposeViewController+URLExtension.h"
#import "AMAudioPlayerViewController.h"
#import "AppMakrNativeLocation.h"
#import "EntryMapViewController.h"
#import "UIButton+Socialize.h"
#import "MoviePlayerController.h"
#import "BlocksKit.h"
#import "AdsViewController.h"
#import "UITapGestureRecognizer+SingleTap.h"
#import "AppMakrShareActionSheet.h"
#import "UIToolbar+CustomImage.h"
#import "UIActionSheet+Utils.h"
#import "AppMakrDateTimeConvertor.h"
#import "CustomNavigationBar.h"
#import "FullscreenEvents.h"

#define FAVORITES_TAB_INDEX 3 // this is the location of the Favorites tab in the app. 

@interface EntryViewController () {
    BOOL _finishedAdjustingWebView;
    BOOL _didReceiveAd;
    BOOL _didResizeForAd;
}
@end

@implementation EntryViewController

@synthesize adsView;
@synthesize webView = _webView;
@synthesize feedBaseUrl = _feedBaseUrl;

#pragma mark - Controller life cycle

- (void)dealloc 
{
	self.webView.delegate = nil;
    
    [socializeActionBar release];
    
    [entry release];
    self.webView = nil;
    self.audioView = nil;
    [currentService release];
    self.adsView = nil;
    self.feedBaseUrl = nil;
    DebugLog(@"XXX completing dealloc entryview controller XXX");
    
	[super dealloc]; 
    
}

- (id)initWithEntryID:(id)objectID
{
    return [self initWithEntryID:objectID service: [[AppMakrSocializeService new]autorelease]];
}

-(id)initWithEntryID:(id)objectID service: (AppMakrSocializeService*)service
{
    Entry* workentry = (Entry *) [service.localDataStore entityWithID:objectID];
    if(workentry == nil)
        return nil;
    
    if ((self = [super initWithNibName:nil bundle:nil])) 
	{	
        currentService = [service retain];
		entry = [workentry retain];
        
      	self.hidesBottomBarWhenPushed = YES;
        contentLoaded = NO;
	}
	return self;
}

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations.
	return [MPMoviePlayerController isOnFullScreenPlayback] || interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
	[super viewDidLoad];
   
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.autoresizesSubviews = YES;
	self.view.backgroundColor = [UIColor whiteColor];
	
	if (entry.title && [[self.properties objectForKey:@"display_details_title"] boolValue]) {
		self.title = entry.title;
	}
  
   
    self.webView = [self createWebView];
	[self.view addSubview:self.webView];
   	
    [self addMediaPlayerContainer];

    self.navigationItem.rightBarButtonItem = [self createWebLinkButton];
	
    //initialize socialize related classes
    [self initSocialize];
	
    //addwebview's gesture recognizer
    [self.webView addGestureRecognizer:[UITapGestureRecognizer createSingleTapRecognizerWithTarget:self action:@selector(tapWebView:)]];
    
    beforeAdLoaded = YES;

    self.toolbarItems = [NSArray arrayWithObjects:
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                         nil
                         ];
    [self.navigationController.toolbar setToolbarBack: @"socialize_resources/action-bar-bg.png"];
    
    /*********** CREATE AD VIEW *************/
    self.adsView = [AdsViewController createFromGlobalConfiguratinWithTitle:@"Detail_view" delegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    self.navigationController.toolbarHidden = self.socializeEnable;

    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
    {
        [((CustomNavigationBar*)self.navigationController.navigationBar) clearBackground];
    }
    self.webView.delegate = self;
} 

- (void)viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];
    [self resize];
    if(!contentLoaded)
        [self resizeWebpage];
    
    [self resizeForAdIfPossible];
}

- (void)viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];   
    
    self.webView.delegate = nil;
    [self.webView stopLoading];
    
    self.adsView.delegate = nil;
    if([self.adsView respondsToSelector:@selector(stopLoad)])
        [self.adsView stopLoad];
    self.navigationController.toolbarHidden =YES;
}

- (void)viewDidDisappear:(BOOL)animated {	
    [super viewDidDisappear:animated];
}

-(void)viewDidUnload:(BOOL)animated{
	self.webView = nil;
}

#pragma mark - Utils
-(BOOL) socializeEnable
{
    NSDictionary* application = (NSDictionary * )[self.properties objectForKey:@"application"];
    return [[application objectForKey:@"socialize_enabled"] boolValue];      
}

-(void)share
{
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
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

-(void)sendMailWithUrl: (NSURL*)url
{
    if ([MFMailComposeViewController canSendMail]) 
    {
        //TODO:: add BlocksKit there
        MFMailComposeViewController *mailer = [MFMailComposeViewController composerWithInfoFromUrl:url withDelegate:self];
        [self presentModalViewController:mailer animated:YES];
    } 
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
                                                        message: NSLocalizedString(@"Failed to open mail composer.", @"")
                                                       delegate: nil 
                                              cancelButtonTitle: NSLocalizedString(@"OK", @"")
                                              otherButtonTitles: nil];
        [alert show];	
        [alert release];
    }
}

- (void)addMediaPlayerContainer {
    UIView* mediaPlayerContainer = [[UIView alloc] init];
	mediaPlayerContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.audioView = mediaPlayerContainer;
	[self.view addSubview:mediaPlayerContainer];
    [mediaPlayerContainer release];
}

-(void)initSocialize{
    if (entry && self.socializeEnable){	
        SZEntity* entity = [SZEntity entityWithKey:entry.url name:entry.title != nil ? entry.title: @""];
        socializeActionBar = [[SZActionBar defaultActionBarWithFrame:CGRectNull entity:entity viewController:self] retain];
        [self.view addSubview:socializeActionBar];      
    }
    else
        socializeActionBar = nil;
}

-(WebpageViewController*)webpageController
{
    appbuildrAppDelegate *appDelegate =  (appbuildrAppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.webpageController;
}

-(NSDictionary*)properties
{
   return [GlobalVariables getPlist];
}

-(NSDictionary*) tabConfiguration
{
    return [GlobalVariables configsForModulePath: self.modulePath];
}

-(UIWebView*) createWebView
{
    UIWebView* webView = [[UIWebView alloc] init];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	           
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    return [webView autorelease];
}

-(UIBarButtonItem*) createWebLinkButton
{
    NSNumber * hideWeblinkButtonNum = (NSNumber *)[[self.properties objectForKey:@"configuration"] 
                                                   objectForKey:@"hide_weblink_button"];
	BOOL hideWeblinkButton = NO;
	if( hideWeblinkButtonNum ) {
		hideWeblinkButton = [hideWeblinkButtonNum boolValue];
	}
	
    UIBarButtonItem *gotoLinkButton = nil;
    
    Link * link = [entry.links count] > 0 ? [[entry linksInOriginalOrder] objectAtIndex:0]:nil;
	if (!hideWeblinkButton && link && link.href && ![link.href isEqualToString:@""] )
    {       
        UIButton* viewInBroswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [viewInBroswerButton setFrame:CGRectMake(-5, 0, 28, 25)];
        [viewInBroswerButton setBackgroundImage:[UIImage imageNamed:@"/socialize_resources/viewinbrowser-icon.png"] forState:UIControlStateNormal];   // default is nil
        
        [viewInBroswerButton addTarget:self action:@selector(actionButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        gotoLinkButton = [[[UIBarButtonItem alloc] initWithCustomView:viewInBroswerButton] autorelease];
	}
    
    return gotoLinkButton;
}

- (void)gotoWebpageView:(NSString *)urlString 
{   
	if([urlString rangeOfString:@"itunes.apple.com"].location != NSNotFound)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}
	else
	{              
		NSDictionary* item = self.tabConfiguration;
		BOOL mobilize = [[item objectForKey:@"use_google_mobilizer"] boolValue];
		
		if(mobilize)
		{
			urlString = [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			urlString = [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			urlString = [NSString stringWithFormat:@"http://www.google.com/gwt/x?u=%@&btnGo=Go&source=wax&ie=UTF-8&oe=UTF-8",urlString];
		}
		
        self.webpageController.entryURL = urlString;
        self.webpageController.entry = entry;
		self.webpageController.parentController = @"desc";	
        
		//should we show the entry title in the header?
		if (entry.title && [[self.properties objectForKey:@"display_details_title"] boolValue]) {
			self.webpageController.title = entry.title;
		}
		[[self navigationController] pushViewController:self.webpageController animated:YES];
		[self.webpageController showWebPageView];
	}
}

-(void)resize
{
    /* setting the container height*/
    float webViewHeight = self.view.bounds.size.height;
    if (CGRectIntersectsRect(self.view.frame, socializeActionBar.frame)) //Action bar is visible
        webViewHeight -= socializeActionBar!=nil ?socializeActionBar.frame.size.height:0;
    
    if(self.adsView.view.superview)
        webViewHeight -= CGRectGetHeight(self.adsView.view.frame);
    
    self.webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, webViewHeight);

    _finishedAdjustingWebView = YES;
}

-(void)appendCssContent: (NSMutableString*)html
{
    NSString* cssContent = [[self.tabConfiguration objectForKey:@"fields"] objectForKey:@"css_snippet"];
    if(cssContent)
        [html appendString:cssContent];
}

-(void)appendJsContent: (NSMutableString*)html
{
    NSString* jsContent = [[self.tabConfiguration objectForKey:@"fields"] objectForKey:@"js_snippet"];
    if(jsContent)
        [html appendString:jsContent];
}

-(NSString*)entryJSDescription
{
    return [NSString stringWithFormat:@"<script src=\"jquery-1.7.2.js\" type=\"text/javascript\" charset=\"utf-8\"></script> \n <script type=\"text/javascript\">%@</script>" , [entry printJSobjectWithTitle:@"appmakr-header-title" author:@"appmakr-header-author" date:@"appmakr-header-date" content:@"appmakr-content"]];
}

-(void)resizeWebpage
{
    if (entry)
    {
        NSDictionary * tabConfig = self.tabConfiguration;
        
        NSMutableString* htmlContent = [[[[tabConfig objectForKey:@"fields"] objectForKey:@"html_snippet"] mutableCopy] autorelease];
        if(!htmlContent)
            htmlContent =  [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"entry_view_header" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
        
        [self appendCssContent:htmlContent];
        [self appendJsContent:htmlContent];
        
        [htmlContent appendString:self.entryJSDescription];
        
        
        Feed* feed = entry.feed;
        if([feed host] && ![[feed host] isEqualToString:@""] && entry.useHost)
        {
            self.feedBaseUrl = [feed host];
        } 
        else
        {
            self.feedBaseUrl = @"";
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
 
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        [self.webView loadHTMLString:htmlContent baseURL:baseURL];
	}    
}

#pragma mark - Tap Gesture Delegate 

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - Actions dispatch

- (void)actionButtonTapped {   
	if ([NetworkCheck hasInternet] && [entry.links count] > 0) {
		Link * link = [[entry linksInOriginalOrder] objectAtIndex:0];
		[self gotoWebpageView:link.href];        
	}
}

-(void)moveActionBarTo: (float)value
{
    [UIView beginAnimations:@"SocializeFrameHide" context:nil];
    [UIView setAnimationDuration:0.25];
    
    socializeActionBar.frame = CGRectOffset(socializeActionBar.frame, 0, value);

    
    self.webView.frame = CGRectMake(self.webView.frame.origin.x, 
                                    self.webView.frame.origin.y, 
                                    self.webView.frame.size.width, 
                                    self.webView.frame.size.height + value); 
    
    if(self.adsView.view.superview)
        self.adsView.view.frame = CGRectOffset(self.adsView.view.frame, 0, value);

    [UIView commitAnimations]; 
    
}

-(void)tapWebView:(NSNotification *)notification 
{
    if(socializeActionBar)
    {       
        if(CGRectIntersectsRect(self.view.frame, socializeActionBar.frame))
            [self moveActionBarTo: socializeActionBar.frame.size.height];//hide
        else
            [self moveActionBarTo: -socializeActionBar.frame.size.height];//show
     
        [self.view bringSubviewToFront:socializeActionBar];
    }
}

#pragma mark - Mail view controller delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];

}

#pragma mark - UIWebViewDelegate methods


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if( navigationType == UIWebViewNavigationTypeLinkClicked)  {
        
		//only do this action if a user has clicked a link
		//pop out to the browser if url has browser:// in it otherwise use in app browser
        
		if( [LinkUtilities hasVideo:[request.URL absoluteString]]) {
			[self playVideoAtURL:request.URL];
			return NO;
		}
		else if([[request.URL absoluteString] rangeOfString:@"playaudio://"].location != NSNotFound) {			
			for( Link *link in entry.links ) {
				if( [link hasAudio]){
					//[[MoviePlayerController getMoviePlayer] playVideoWithLink:mediaLink videoView:mediaPlayerContainer];
					//[self playAudioWithLink:mediaLink];
					AMAudioPlayerViewController *audioPlayer = [AMAudioPlayerViewController sharedInstance];
					NSURL *audioURL = [NSURL URLWithString:link.href];
					[audioPlayer loadAudioURL:audioURL];		
					return NO;
				}
			}	
		}
		else if([[request.URL absoluteString] rangeOfString:@"playvideo://"].location != NSNotFound) {			
			for( Link *link in entry.links ) {
				if( [link hasVideo]){
					[self playVideoWithLink:link];					
					return NO;
				}
			}
		}
		else if([[request.URL absoluteString] rangeOfString:@"showmap://"].location != NSNotFound) {			
			AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
			EntryMapViewController * entryMapViewController = [[EntryMapViewController alloc] initWithEntry:entry userLocation:location.lastKnownLocation];
			[self.navigationController pushViewController:entryMapViewController animated:YES];
			[entryMapViewController release];
		}
		else if([[request.URL absoluteString] rangeOfString:@"browser://"].location != NSNotFound) {
            
			NSString *urlString = [request.URL absoluteString];
			urlString = [urlString stringByReplacingOccurrencesOfString:@"browser://" withString:@"http://"];
			NSURL *requestURL = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:requestURL];
			return NO;			
            
		} else if ([request.URL.scheme isEqualToString:@"mailto"]){
			
			[self sendMailWithUrl: request.URL];
			return NO;
		}else if([request.URL.scheme isEqualToString:@"file"]){
            NSString *urlString = [request.URL absoluteString];
			urlString = [urlString stringByReplacingOccurrencesOfString:@"file://" withString:self.feedBaseUrl];
            
            [self gotoWebpageView:urlString];
            return NO;
        }else
        {
			[self gotoWebpageView: [[request URL] absoluteString]];
			return NO;
		}
	}
	
	return YES;
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
	for(Link *link in entry.links ) {
		if( [link hasAudio] ) {	
			[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('appmakr-media-audio').style.display='block';"];
		}
		
		if( [link hasVideo] ) {
			[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('appmakr-media-video').style.display='block';"];	
		}
		if( [link hasImage] && (![entry.type isEqualToString:@"twitterSearch"] &&  ![entry.type isEqualToString:@"twitterUserTimeline"])) {
			[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('appmakr-media-photo').style.display='block';"];					
			NSString *href = [NSString stringWithFormat:@"document.getElementById('appmakr-media-photo').href='%@';", link.href];
			[webView stringByEvaluatingJavaScriptFromString:href];	
		}
	}
	
	if ([entry geoPoint]){
		[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('appmakr-media-geo').style.display='block';"];					
	}
	
	//add image for twitter
    if([entry.type isEqualToString:@"twitterSearch"] || 
       ([entry.type isEqualToString:@"twitterUserTimeline"] && entry.thumbnailImage)) {
		DebugLog(@"adding thumbnail for twitter");
		NSString *js = [NSString stringWithFormat:@"document.getElementById('appmakr-thumbnail-image').src='%@';", entry.thumbnailURL];		
		[webView stringByEvaluatingJavaScriptFromString:js];
		[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('appmakr-thumbnail-image').style.display='inline';"];		
    }
    
    contentLoaded = YES;
}

- (void)resizeForAdIfPossible {
    if(!_didResizeForAd && _didReceiveAd && _finishedAdjustingWebView)
    {
        CGRect frame = self.webView.frame;
        frame.size.height -= 49;
        self.webView.frame = frame;
        
        self.adsView.view.frame = CGRectMake(0, self.webView.frame.size.height, self.webView.frame.size.width, 49);
        [self.view addSubview:self.adsView.view];
        
        _didResizeForAd = YES;
    }
}

#pragma mark Ad Methods
- (void) adReceived  {
    _didReceiveAd = YES;
    [self resizeForAdIfPossible];
}

@end