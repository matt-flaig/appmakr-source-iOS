//
//  WebpageController.m
//  appbuildr
//
//  Created by PointAboutAdmin on 3/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebSliderViewController.h"
#import "GlobalVariables.h"

@implementation WebSliderViewController
@synthesize webpageView;
@synthesize statusBarWasHiden;

static WebSliderViewController* wp = nil;


/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	DebugLog(@"I've reached WebpageController");
	
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat barHeight = 44.f;
    
	wp.view.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight);
	// create a uiwebview which is 320x460~ and add it to the uiview by sending the message [addSubview: ];
	webpageView = [[UIWebView alloc] initWithFrame: CGRectMake(0.0, 0.0, screenWidth, screenHeight - barHeight)];
	webpageView.delegate = self;
	webpageView.scalesPageToFit = YES;
	
	// add a toolbar to the new uiview
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, screenHeight - barHeight, 320, barHeight)];
	
	NSDictionary *headerBgDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( headerBgDict ) {
		CGFloat bgRed = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[headerBgDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[headerBgDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		UIColor *headerBgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
		toolbar.tintColor = headerBgColor;
	}
	
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadpageView)];
	
	backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backpageView)];
	backButton.enabled = NO;
	
	forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardpageView)];
	[forwardButton setWidth:50];
	forwardButton.enabled = NO;
	
	UIBarButtonItem *flexibleSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(closeView)];
	[closeButton setWidth:57];
	
	[toolbar setItems:[NSArray arrayWithObjects:backButton, flexibleSpaceButton, forwardButton, flexibleSpaceButton, closeButton, flexibleSpaceButton, reloadButton, nil] animated:YES];
	toolbar.barStyle = UIBarStyleDefault;
	
	CGRect spinnerFrame = CGRectMake(50, 10, 25.0, 25.0);
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:spinnerFrame];
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	[toolbar addSubview:spinner];
	
	// add the subviews
	[wp.view addSubview:webpageView];
	[wp.view addSubview:toolbar];
	
	[toolbar release];
	[reloadButton release];

	[forwardButton release];
	[flexibleSpaceButton release];
	[closeButton release];
	
}

+ (void) popOut:(NSURLRequest *)request forView:(UIView*)view {
	DebugLog(@"called popuot method");
	@synchronized(self) {
        if (wp == nil) {
            [[self alloc] init]; // assignment not done here
        } 
		
		[view addSubview: wp.view];

        
		[wp.webpageView loadRequest:request];
        [UIView animateWithDuration:1.0 animations:^{
            wp.view.frame = view.frame;
        } completion:^(BOOL finished) {
            if ([UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
            }
        }];

        // Status Bar
        wp.statusBarWasHiden = [UIApplication sharedApplication].statusBarHidden;
	}
}

/*
 - (void)hideWebPageView {
 
 }
 */
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (wp == nil) {
            wp = [super allocWithZone:zone];
            return wp;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DebugLog(@"did fail with error");
	DebugLog(@"error is: %@", [error description]);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	// Before page is loaded start animation
	webpageView.scalesPageToFit = YES;
	[spinner startAnimating];
	DebugLog(@"started loading in WebpageController");
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self checkForMovement];
	// After page is loaded stop animation
	[spinner stopAnimating];
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
	DebugLog(@"reload the pageview");
	[wp.webpageView reload];
}


- (IBAction)backpageView {
	DebugLog(@"go to previous pageview");
	[wp.webpageView goBack];
}

- (IBAction)forwardpageView {
	DebugLog(@"go to next pageview");
	[wp.webpageView goForward];
}

- (void)closeView {
	DebugLog(@"close the pageview");
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;

    [UIView animateWithDuration:1.0 animations:^{
        self.view.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
    }];

    if (!statusBarWasHiden && [UIApplication instancesRespondToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES?UIStatusBarAnimationFade:UIStatusBarAnimationNone];
    }

	// self.view.hidden = YES;
    // Status Bar
	DebugLog(@"closed the pageview successfully");
	[self performSelector:@selector(clearWebpageView) withObject:nil afterDelay:1.0];
}

-(void)clearWebpageView
{
	[webpageView loadHTMLString:@"<html></html>" baseURL:nil];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[webpageView release];
	[spinner release];
    [super dealloc];
}


@end
