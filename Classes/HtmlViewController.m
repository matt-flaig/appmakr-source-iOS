//
//  HtmlViewController.m
//  appbuildr
//
//  Created by Sergey Popenko on 2/15/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "HtmlViewController.h"
#import <PhoneGap/PGViewController.h>
#import "AdsViewController.h"
#import "GlobalVariables.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MFMailComposeViewController+URLExtension.h"
#import "CustomNavigationBar.h"
#import "ModuleFactory.h"
#import "SZPathBar.h"
#import "SZPathBar+Default.h"

@interface HtmlViewController()
@property (nonatomic, retain) id<AdsController>  adManager;
@property (nonatomic, retain) PGViewController* pgViewController;
@end

@implementation HtmlViewController
@synthesize adManager = _adManager;
@synthesize pgViewController = _pgViewController;
@synthesize pageName = _pageName;

-(void)dealloc
{
    self.adManager = nil;
    self.pgViewController = nil;
    self.pageName = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([GlobalVariables templateType] == AppMakrScrollTemplate)
    {           
        self.navigationItem.leftBarButtonItem = [self createBackToMainMenuBtnItem];
    }
    
    NSDictionary *headerBgDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( headerBgDict ) {
		CGFloat bgRed = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[headerBgDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		UIColor *headerBgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
		self.navigationController.navigationBar.tintColor = headerBgColor;
	}
    
    if(self.headerImage && [self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
       [((CustomNavigationBar*)self.navigationController.navigationBar) setBackgroundWith:self.headerImage];
    
    self.title = self.headerImage ? nil : [ModuleFactory tabTitle:[GlobalVariables configsForModulePath:self.modulePath]];

    
    self.pgViewController = [[PGViewController new] autorelease];
    self.pgViewController.wwwFolderName = [NSString stringWithFormat: @"phonegap_www/%@", self.pageName];
    self.pgViewController.startPage = @"index.html";
    self.pgViewController.view.frame = [[UIScreen mainScreen] applicationFrame];
    self.pgViewController.webView.delegate = self;

   [self.view addSubview:self.pgViewController.view];

    if([GlobalVariables socializeEnable] && [GlobalVariables templateType] == AppMakrScrollTemplate)
    {
        bar = [[SZPathBar alloc] initWithButtonsMask: SZCommentsButtonMask|SZShareButtonMask|SZLikeButtonMask
                                parentController: (UIViewController*)self.pointAboutTabBarScrollViewController ? (UIViewController*)self.pointAboutTabBarScrollViewController: self
                                          entity: [SZEntity entityWithKey:self.pgViewController.wwwFolderName  name:self.pageName]];
    
        [bar applyDefaultConfigurations];    
        [self.view addSubview:bar.menu];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([GlobalVariables templateType] != AppMakrScrollTemplate)
        self.navigationController.navigationBar.hidden = YES;
    
    self.pgViewController.view.frame = self.view.frame;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.adManager = [AdsViewController createFromGlobalConfiguratinWithTitle:@"" delegate:self];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    self.adManager.delegate = nil;
    if([self.adManager respondsToSelector:@selector(stopLoad)])
        [self.adManager stopLoad];
    [self.adManager.view removeFromSuperview];
    self.adManager = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.adManager = nil;
    self.pgViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - ads
-(void) presentAds
{
    if(self.adManager.view.superview == nil)
    {
        CGRect newPhoneGapFrame = self.pgViewController.view.frame;
        newPhoneGapFrame.size.height -= 49;
        self.pgViewController.view.frame = newPhoneGapFrame;
        
        CGRect adFrame = CGRectMake(0, self.pgViewController.view.frame.size.height, self.pgViewController.view.frame.size.width, 49);
        self.adManager.view.frame = adFrame;
        [self.view addSubview:self.adManager.view];
    }
}

-(void)adReceived
{  
    [self presentAds];
}

#pragma mark web view delegate

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    /*
     * Get Command and Options From URL
     * We are looking for URLS that match gap://<Class>.<command>/[<arguments>][?<dictionary>]
     * We have to strip off the leading slash for the options.
     */
	if([[request.URL absoluteString] rangeOfString:@"browser://"].location != NSNotFound) {
		
		NSString *urlString = [request.URL absoluteString];
		urlString = [urlString stringByReplacingOccurrencesOfString:@"browser://" withString:@"http://"];
		NSURL *requestURL = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:requestURL];
		return NO;			
        
	} else if ([request.URL.scheme isEqualToString:@"mailto"]){
		
		if ([MFMailComposeViewController canSendMail]) {
			MFMailComposeViewController *mailer = [MFMailComposeViewController composerWithInfoFromUrl:request.URL withDelegate:nil];
			[self.pgViewController presentModalViewController:mailer animated:YES];
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
															message: NSLocalizedString(@"Failed to open mail composer.", @"")
														   delegate: nil 
												  cancelButtonTitle: NSLocalizedString(@"OK", @"")
												  otherButtonTitles: nil];
			[alert show];	
			[alert release];
		}
		return NO;
	}
    
    NSURL *url = [request URL];
    if ([[url scheme] isEqualToString:@"gap"] || [url isFileURL])
	{
		return [self.pgViewController webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
	}
	return YES;
}

@end
