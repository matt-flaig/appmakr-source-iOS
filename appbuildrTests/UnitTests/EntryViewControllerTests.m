//
//  EntryViewControllerTests.m
//  appbuildr
//
//  Created by Sergey Popenko on 11/11/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import "EntryViewControllerTests.h"
#import "DataStore.h"
#import "Entry.h"
#import "Link.h"
#import "AdsViewController.h"
#import "GHTestCase+Swizzle.h"
#import "NetworkCheck.h"
#import "Entry+Extensions.h"
#import "Link+Extensions.h"
#import "LinkUtilities.h"
#import "MasterController.h"
#import "AMAudioPlayerViewController.h"
#import  <OCMock/OCMock.h>
#import <Socialize/Socialize.h>

#define ENTRY_TITLE @"Test"
#define ENTRY_ID @"123"
#define TEST_LINK @"test-link"

@interface EntryViewController(Private)
    -(void) adRequestSucceeded;
@end

@implementation EntryViewControllerTests

- (BOOL)shouldRunOnMainThread
{
    return YES;
}

-(BOOL)hasInternet
{
    return internetStatus;
}

-(UIApplication*) sharedApplication
{
    id mockApp = [OCMockObject mockForClass:[UIApplication class]];
    [[mockApp expect] openURL:OCMOCK_ANY];
    return  mockApp;
}

-(BOOL)hasVideo:(NSString*)url
{
    return YES;
}

-(id)sharedInstance
{
    return nil;
}

- (id)defaultActionBarWithFrame:(CGRect)frame entity:(id<SZEntity>)entity viewController:(UIViewController*)viewController
{
    return  [OCMockObject niceMockForClass:[SZActionBar class]];
}

-(void)setUp
{
    id mockService = [OCMockObject mockForClass: [AppMakrSocializeService class]];
    id mockDataStore = [OCMockObject mockForClass:[DataStore class]];
    [[[mockService stub]andReturn:mockDataStore]localDataStore];
    
    mockEntry = [OCMockObject mockForProtocol:@protocol(Entry)];
    [[[mockDataStore stub]andReturn:mockEntry]entityWithID:ENTRY_ID];
    
    [[[mockEntry stub]andReturn:ENTRY_TITLE]title];
    
    controller = [[EntryViewController alloc] initWithEntryID:ENTRY_ID service: mockService];
}

-(void)tearDown
{
    [controller release]; controller = nil;
}

-(void) testEntryViewControllerInit
{
    GHAssertNotNil([controller valueForKey:@"entry"], nil);
    GHAssertTrue(controller.hidesBottomBarWhenPushed == YES, nil);
}

-(void) testEntryViewControllerInitById
{
    id mockController = [OCMockObject partialMockForObject:controller];
    [[mockController expect]initWithEntryID:@"123" service: OCMOCK_ANY];

    [mockController initWithEntryID:@"123"];
    
    [mockController verify];
}

-(void)testActionBtnPressed
{
    id mockController = [OCMockObject  partialMockForObject:controller];
    [[mockController expect]gotoWebpageView:TEST_LINK];
    
    SwizzleSelector* mockHasInternet = [self swizzle:[NetworkCheck class] selector:@selector(hasInternet)];
    internetStatus = YES;
    
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    [[[mockEntry expect]andReturn:links] linksInOriginalOrder];
    
    [[[mockLink stub]andReturn:TEST_LINK]href];
    
    [mockController actionButtonTapped];
    
    [mockHasInternet deswizzle];
    [mockController verify];
}

-(void)testClickOnVideoUrl
{
    id mockController = [OCMockObject  partialMockForObject:controller];

    NSURL* url = [NSURL URLWithString:@"test"];
    [[mockController expect]playVideoAtURL:url];
    
    SwizzleSelector* mockIsVideo = [self swizzle:[LinkUtilities class] selector:@selector(hasVideo:)];
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];

    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
        
    [mockController verify];
    [mockIsVideo deswizzle];
}

-(void)testClickPlayAudio
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 

    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    
    BOOL value = YES;
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasAudio];
    [[[mockLink stub]andReturn:@"playaudio://test"]href];
    
    NSURL* url = [NSURL URLWithString:@"playaudio://test"];  
    
    SwizzleSelector*ss = [self swizzle:[AMAudioPlayerViewController class] selector:@selector(sharedInstance)];
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
    
    [mockController verify];
    [mockLink verify];
    [ss deswizzle];
}

-(void)testClickPlayVideo
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
    [[mockController expect] playVideoWithLink:OCMOCK_ANY];
    
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    
    BOOL value = YES;
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasVideo];
    [[[mockLink stub]andReturn:@"playvideo://test"]href];
    
    NSURL* url = [NSURL URLWithString:@"playvideo://test"];  
       
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
   
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
    
    [mockController verify];
    [mockLink verify];
}

-(void)testClickShowMap
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
    
    NSURL* url = [NSURL URLWithString:@"showmap://test"];  
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertTrue(expectedResult, nil);
    
    [mockController verify];
}

-(void)testClickOpenInBrowser
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
    
    NSURL* url = [NSURL URLWithString:@"browser://test"];  
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    SwizzleSelector *mockShareApplication = [self swizzle:[UIApplication class] selector:@selector(sharedApplication)];
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
    
    [mockController verify];
    [mockShareApplication deswizzle];
}

-(void)testClickSendMail
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 

    NSURL* url = [NSURL URLWithString:@"mailto://test"];  
    
    [[mockController expect]sendMailWithUrl:url];
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
    
    [mockController verify];
}

-(void)testClickWebPage
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
    
    NSURL* url = [NSURL URLWithString:@"http://test"];  
    [[mockController expect] gotoWebpageView: [url absoluteString]]; 
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];    
    id mockRequest = [OCMockObject mockForClass:[NSURLRequest class]];
    [[[mockRequest stub]andReturn:url]URL];
    
    
    BOOL expectedResult =  [mockController webView:mockWebView shouldStartLoadWithRequest:mockRequest navigationType:UIWebViewNavigationTypeLinkClicked];
    GHAssertFalse(expectedResult, nil);
    
    [mockController verify];
}

-(void)testContinueLoadPage
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
       
    BOOL expectedResult =  [mockController webView:nil shouldStartLoadWithRequest:nil navigationType:UIWebViewNavigationTypeOther];
    GHAssertTrue(expectedResult, nil);
    
    [mockController verify];
}

-(void)testCompleteLoad
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 

    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    
    BOOL value = YES;
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasVideo];
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasAudio];
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasImage];
    [[[mockLink stub]andReturn:@"test"]href];
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];   
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString: @"document.getElementById('appmakr-media-audio').style.display='block';"];
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString: @"document.getElementById('appmakr-media-video').style.display='block';"];
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString: @"document.getElementById('appmakr-media-photo').style.display='block';"];
    NSString *href = [NSString stringWithFormat:@"document.getElementById('appmakr-media-photo').href='%@';", @"test"];
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString:href];
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString: @"document.getElementById('appmakr-media-geo').style.display='block';"];
    
    [(Entry*)[[mockEntry stub]andReturn:@"nottwitterSearch"]type];
    [[[mockEntry stub]andReturn:[OCMArg isNotNil]]geoPoint];
    
    [mockController webViewDidFinishLoad:mockWebView];
    
    
    [mockWebView verify];
    [mockController verify];
}

-(void)testCompleteLoadWithTwiterSearchEntryType
{
    id mockController = [OCMockObject  partialMockForObject:controller]; 
    
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    
    BOOL value = NO;
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasVideo];
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasAudio];
    [[[mockLink expect]andReturnValue:OCMOCK_VALUE(value)]hasImage];
    [[[mockLink stub]andReturn:@"test"]href];
    
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];   
     NSString *js = [NSString stringWithFormat:@"document.getElementById('appmakr-thumbnail-image').src='%@';", @"url"];	
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString: js];
    [[mockWebView expect]stringByEvaluatingJavaScriptFromString:     @"document.getElementById('appmakr-thumbnail-image').style.display='inline';"];
    
    [(Entry*)[[mockEntry stub]andReturn:@"twitterSearch"]type];
    [[[mockEntry stub]andReturn:nil]geoPoint];
    [(Entry*)[[mockEntry stub]andReturn:@"url"]thumbnailURL];
    [mockController webViewDidFinishLoad:mockWebView];
    
    
    [mockWebView verify];
    [mockController verify];
}

-(void)testSupportOrientation
{
    GHAssertTrue ([controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait], nil);
    GHAssertFalse ([controller shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft], nil);
}

//-(void)testCreateWebView
//{
//    UIWebView* webView = [controller createWebView];
//    GHAssertTrue(webView.delegate == controller,nil);
//    GHAssertTrue(webView.autoresizingMask == (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight),nil);
//    GHAssertTrue(webView.scalesPageToFit,nil);
//    GHAssertTrue(webView.dataDetectorTypes == UIDataDetectorTypeLink,nil);
//}

-(void)testEnableGetstrucureRecognizer
{
    GHAssertTrue([controller gestureRecognizer:nil shouldRecognizeSimultaneouslyWithGestureRecognizer:nil], nil);
}

-(void)testSocializeEnable
{   
    id mockController = [OCMockObject  partialMockForObject:controller];
    NSDictionary * application = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"socialize_enabled",  nil] autorelease];
    NSDictionary * properties = [[[NSDictionary alloc] initWithObjectsAndKeys:application,@"application", nil]autorelease];
    [[[mockController stub]andReturn:properties]properties];
    
    id mockSelfView = [OCMockObject mockForClass:[UIView class]];
    [[[mockController stub]andReturn:mockSelfView]view];
    [[mockSelfView expect]addSubview:OCMOCK_ANY];
    
    [[[mockEntry stub]andReturn:@"test_url"]url];
    
     SwizzleSelector* createBarSelector = [self swizzle:[SZActionBar class] selector:@selector(defaultActionBarWithFrame:entity:viewController:)];
    
    [mockController initSocialize];
    SZActionBar* actionBar = [mockController valueForKey:@"socializeActionBar"];
    GHAssertNotNil(actionBar, nil);
    
    [mockController verify];
    [mockEntry verify];
    [createBarSelector deswizzle];
}

-(void)testSocializeDisable
{   
    id mockController = [OCMockObject  partialMockForObject:controller];
    NSDictionary * application = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"socialize_enabled",  nil] autorelease];
    NSDictionary * properties = [[[NSDictionary alloc] initWithObjectsAndKeys:application,@"application", nil]autorelease];
    [[[mockController stub]andReturn:properties]properties];
       
    [mockController initSocialize];
    SZActionBar* actionBar = [mockController valueForKey:@"socializeActionBar"];
    GHAssertNil(actionBar, nil);
    
    [mockController verify];
}

-(void) testAddMediaPlayerContainer
{
    id mockController = [OCMockObject  partialMockForObject:controller];
    UIView *view = [[[UIView alloc]initWithFrame:CGRectMake(0,0,320, 460)]autorelease];
    [[[mockController stub]andReturn:view]view]; 
   
    [mockController addMediaPlayerContainer];
    UIView* mediaContainer = [mockController audioView];
    GHAssertTrue(mediaContainer.autoresizingMask == UIViewAutoresizingFlexibleWidth, nil);
    
    [mockController verify];
}

-(void) testAdReceiveCallback
{
    id mockController = [OCMockObject  partialMockForObject:controller];
    id mockView = [OCMockObject niceMockForClass:[UIView class]];
    [[[mockController stub]andReturn:mockView ] view];
    [[mockView expect] setNeedsLayout];
    
    [mockController adReceived];
    
    [mockController verify];
}

-(void) testCreateWebBtnSuccess
{
    id mockController = [OCMockObject  partialMockForObject:controller];
    NSDictionary * configuration = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"hide_weblink_button",  nil] autorelease];
    NSDictionary * properties = [[[NSDictionary alloc] initWithObjectsAndKeys:configuration,@"configuration", nil]autorelease];
    [[[mockController stub]andReturn:properties]properties];
    
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    [[[mockEntry expect]andReturn:links] linksInOriginalOrder];
    
    [[[mockLink stub]andReturn:TEST_LINK]href];
    
    GHAssertNotNil([mockController createWebLinkButton], nil);

    [mockController verify];
    [mockEntry verify];
    [mockLink   verify];
}

-(void) testCreateWebBtnHideWebLink
{
    id mockController = [OCMockObject  partialMockForObject:controller];
    NSDictionary * configuration = [[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"hide_weblink_button",  nil] autorelease];
    NSDictionary * properties = [[[NSDictionary alloc] initWithObjectsAndKeys:configuration,@"configuration", nil]autorelease];
    [[[mockController stub]andReturn:properties]properties];
    
    id mockLink = [OCMockObject mockForProtocol:@protocol(Link)];
    NSArray* links = [NSArray arrayWithObject:mockLink];
    [[[mockEntry stub]andReturn:links]links];
    [[[mockEntry expect]andReturn:links] linksInOriginalOrder];
    
    [[[mockLink stub]andReturn:TEST_LINK]href];
    
    GHAssertNil([mockController createWebLinkButton], nil);
    
    [mockController verify];
    [mockEntry verify];
    [mockLink   verify];
}

@end
