//
//  SA_OathTest.m
//  appbuildr
//
//  Created by akuzmin on 7/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "SA_OathTest.h"

@implementation SA_OAuthTwitterUnitTestController

- (void)createWebView:(UIWebView *)webView {
    _webView = webView;
}

- (id) initWithEngine: (SA_OAuthTwitterEngine *) engine andOrientation:(UIInterfaceOrientation)theOrientation {
    //this method differs from original SA_OAuthTwitterController
    //initialization of webView triggers Bus Error, so removed from this method
	if ((self = [super init])) {
		self.engine = engine;
		self.orientation = theOrientation;
		_firstLoad = YES;
	}
	return self;
}

@end

@implementation SA_OathTest

- (void) setUp {
    NSObject *engine = [OCMockObject niceMockForClass:[SA_OAuthTwitterEngine class]];
    controller = [[SA_OAuthTwitterUnitTestController alloc] initWithEngine:(SA_OAuthTwitterEngine *)engine andOrientation:UIInterfaceOrientationPortrait];
} 

- (void) tearDown {
    //deallocation causes [GHTesting runTestWithTarget:selector:exception:interval:raiseExceptions:] and test fails
    //probably the problem is with VC view or usage of OCMockObjects and there releasing
    //[controller release];
    //controller = nil;
} 

- (void)test_SA_OAuth_webViewDidFinishLoad {
    NSObject *webView = [OCMockObject niceMockForClass:[UIWebView class]];
    UIWebView *webViewForInstance = [OCMockObject niceMockForClass:[UIWebView class]];
    [(SA_OAuthTwitterUnitTestController *)controller createWebView:webViewForInstance];
    //if next method execution will not fail than test succeeded
    [controller webViewDidFinishLoad: (UIWebView *) webView];
}

@end
