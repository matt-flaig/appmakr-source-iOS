//
//  CustomAdView.m
//  ;
//
//  Created by Isaac Mosquera on 8/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomAdView.h"
#import "WebSliderViewController.h"
#import "appbuildrAppDelegate.h"

@implementation CustomAdView
@synthesize proxyDelegate;



- (id)initWithFrame:(CGRect)aRect id:(id<AdsControllerCallback>)calledObject {
	self = [super initWithFrame:aRect];
    if(self)
    {
        self.userInteractionEnabled = YES;
        proxyDelegate = calledObject;
        self.delegate = self;
    }
	return self;
}

-(void)dealloc
{
    self.proxyDelegate = nil;
    [super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if( navigationType == UIWebViewNavigationTypeLinkClicked ||  navigationType == UIWebViewNavigationTypeFormSubmitted ) {
		appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
		NSURLRequest *m = [NSURLRequest requestWithURL:[request URL]];
		[WebSliderViewController popOut:m forView:appDelegate.window];
		return NO;
	}
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	if( proxyDelegate ) {
		[proxyDelegate adReceived];
	}
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Load error occured %@", [error localizedDescription]);
}

@end
