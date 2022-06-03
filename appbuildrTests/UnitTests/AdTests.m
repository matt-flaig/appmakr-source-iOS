/*
 * AdTests.m
 * appbuildr
 *
 * Created on 5/28/12.
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
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import "AdTests.h"
#import "NSObject+BlocksKit.h"
#import <OCMock/OCMock.h>
#import "GlobalVariables.h"
#import "AdsViewController.h"
#import "AdUponController.h"
#import "CustomAdsController.h"
#import "AdmobAdsController.h"
#import "MillennialController.h"
#import "NSString+AdUpon.h"
#import "GHTestCase+Swizzle.h"
#import "AppMakrNativeLocation.h"
#import "UIView+Scrolling.h"

static id mockAppMakrNativeLocation = nil;

@interface AppMakrNativeLocation(Unit_test)
+(AppMakrNativeLocation*)test_sharedInstance;
@end
@implementation AppMakrNativeLocation(Unit_test)

+ (void)prepareForTest
{
    [self swizzleClassSelector:@selector(sharedInstance) withSelector:@selector(test_sharedInstance)];
}

+ (void)afterTest
{
    [self swizzleClassSelector:@selector(test_sharedInstance) withSelector:@selector(sharedInstance)];
}

+(AppMakrNativeLocation*)test_sharedInstance
{
    return mockAppMakrNativeLocation;
}

@end


@interface CustomAdsController(Unit_test)
- (CustomAdView*)createAdsView:(id)delegate frame:(CGRect)frame;
@end

@interface AdmobAdsController()
    -(GADBannerView*)createAdmobView: (CGRect) frame;
@end

@interface MillennialController()
    -(MMAdView*)createMmAds: (CGRect) frame tag:(NSString*)tag;
@end

@interface AdTests()
    -(void)updateConfigsWithFile:(NSString*)name ofType:(NSString*)type;
@end

@implementation AdTests

- (BOOL)shouldRunOnMainThread
{
    return YES;
}

-(void)setUpClass
{
    savedProperties = [GlobalVariables getPlist];
}

-(void)tearDownClass
{
    [GlobalVariables vars].plist = savedProperties;
}

-(void)setUp
{
    mockAppMakrNativeLocation = [[OCMockObject mockForClass:[AppMakrNativeLocation class]] retain];
}
-(void)tearDown
{
    [mockAppMakrNativeLocation release]; mockAppMakrNativeLocation =  nil;
}

#pragma mark ads factory

-(void)testHelperMethods
{
    [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
    
    GHAssertEqualStrings(@"adupon", [AdsViewController adType], @"Should be equals");
    GHAssertEqualStrings(@"adupon", [AdsViewController adTag], @"Should be equals");
}

-(void)testAdsAvailable
{
    [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
    GHAssertTrue([AdsViewController isAdsAvailible], @"Should be abailable for adupon.plist");
}

-(void)testAdsNotAvailable
{
    [self updateConfigsWithFile:@"noads" ofType:@"plist"];
    GHAssertFalse([AdsViewController isAdsAvailible], @"Should be not abailable for noads_congif.plist");
    GHAssertNil([AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil],@"");
}

-(void)testCreateAduponController
{
   [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
    id<AdsController> controller = [AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil];
    GHAssertTrue([controller isKindOfClass:[AdUponController class]], @"");
}

-(void)testCreateCustomAdsController
{
    [self updateConfigsWithFile:@"custom" ofType:@"plist"];
    id<AdsController> controller = [AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil];
    GHAssertTrue([controller isKindOfClass:[CustomAdsController class]], @"");
}

-(void)testCreateAdmobController
{
    [self updateConfigsWithFile:@"admob" ofType:@"plist"];
    id<AdsController> controller = [AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil];
    GHAssertTrue([controller isKindOfClass:[AdmobAdsController class]], @"");
}

-(void)testCreateMillennialController
{
    [self updateConfigsWithFile:@"millennial" ofType:@"plist"];
    id<AdsController> controller = [AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil];
    GHAssertTrue([controller isKindOfClass:[MillennialController class]], @"");
}

-(void)testCreateUnknownAds
{
    [self updateConfigsWithFile:@"newAds" ofType:@"plist"];
    GHAssertNil([AdsViewController createFromGlobalConfiguratinWithTitle:@"test" delegate:nil],@"");
}

#pragma mark adupon string extention

-(void)testCreateAdUponRequestUrl
{
    [AppMakrNativeLocation prepareForTest];
  
    @try {
        BOOL startedStatus = YES;
        [[[mockAppMakrNativeLocation stub]andReturnValue:OCMOCK_VALUE(startedStatus)]started];
        
        CLLocation* location = [[CLLocation alloc] initWithLatitude:1 longitude:2];
        [[[mockAppMakrNativeLocation stub]andReturn:location]lastKnownLocation];
        
        
        [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
        NSString* expectedString = [NSString stringWithFormat:@"http://adproxy.mobi/mproxy/f/2/101/10001/w.320/h.50/d.%@/rn/app.unit_test/aid.10001/lt.1.000000/lg.2.000000", @""];
        NSString* actualString = [NSString createAdUponRequestUrl];
        GHAssertEqualStrings(actualString, expectedString,@""); 
        
        [mockAppMakrNativeLocation verify];  
    }
    @finally {
        [AppMakrNativeLocation afterTest];
    }   
}

-(void)testCreateAdUponRequestUrlStartLocationManager
{
    [AppMakrNativeLocation prepareForTest];
    
    @try {
        BOOL startedStatus = NO;
        [[[mockAppMakrNativeLocation stub]andReturnValue:OCMOCK_VALUE(startedStatus)]started];
        
        [(AppMakrNativeLocation*)[mockAppMakrNativeLocation expect] start];
        
        [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
        NSString* expectedString = [NSString stringWithFormat:@"http://adproxy.mobi/mproxy/f/2/101/10001/w.320/h.50/d.%@/rn/app.unit_test/aid.10001", @""];
        NSString* actualString = [NSString createAdUponRequestUrl];
        GHAssertEqualStrings(actualString, expectedString,@""); 
        
        [mockAppMakrNativeLocation verify]; 
    }
    @finally {
        [AppMakrNativeLocation afterTest];
    }
}

-(void)testCreateAdUponRequestUrlWithNilLocation
{
    [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
    NSString* expectedString = [NSString stringWithFormat:@"http://adproxy.mobi/mproxy/f/2/101/10001/w.320/h.50/d.%@/rn/app.unit_test/aid.10001", @""];
    NSString* actualString = [NSString createAdUponRequestUrlWithLocation:nil];  

    GHAssertEqualStrings(actualString, expectedString,@"");
}
    
-(void)testCreateAdUponRequestUrlWithLocation
{
    [self updateConfigsWithFile:@"adupon" ofType:@"plist"];
    NSString* expectedString = [NSString stringWithFormat:@"http://adproxy.mobi/mproxy/f/2/101/10001/w.320/h.50/d.%@/rn/app.unit_test/aid.10001/lt.1.000000/lg.2.000000", @""];
    NSString* actualString = [NSString createAdUponRequestUrlWithLocation:[[[CLLocation alloc] initWithLatitude:1 longitude:2] autorelease]];  
    
    GHAssertEqualStrings(actualString, expectedString,@"");  
}
    
#pragma mark Custom ads controller tests

-(void) testCustomAdsController
{
    id mockAdsView = nil;
    @autoreleasepool {
        CustomAdsController* controller = [[[CustomAdsController alloc]init] autorelease];
        id mockController = [OCMockObject partialMockForObject:controller];
        
        mockAdsView = [[OCMockObject mockForClass:[CustomAdView class]] retain];
        [[[mockController expect]andReturn:mockAdsView]createAdsView:OCMOCK_ANY frame:CGRectZero];
        
        //on init
        [[mockAdsView expect]loadRequest:OCMOCK_ANY];
        [[mockAdsView expect]disableScrolling];
        
        [mockController initWithFrame:CGRectZero andUrl:[NSURL new] delegate:nil];
        
        //on delegate set/get
        [[mockAdsView expect]setProxyDelegate:OCMOCK_ANY];
        [[[mockAdsView expect]andReturn:self]proxyDelegate];
        
        [mockController setDelegate:self];
        GHAssertEquals(self, [mockController delegate], @"");
        
        //on reload
        BOOL loading = NO;
        [[[mockAdsView stub]andReturnValue:OCMOCK_VALUE(loading)] isLoading];
        [[mockAdsView expect] reload];
        
        [mockController reload];
        
        //on get view
        
        GHAssertEquals(mockAdsView, [mockController view], @"");
        
        
        //on stop load
        [[mockAdsView expect] stopLoading];
        [mockController stopLoad];
        
        //on dealoc
        [[mockAdsView expect]stopLoading];
        [[mockAdsView expect]setDelegate:nil];       
        
        [mockController verify];
    }

    [mockAdsView verify];
    [mockAdsView release];
}

#pragma mark adupon controller test
-(void) testAduponControllerTest
{
    id mockAdsView = [OCMockObject mockForClass:[CustomAdView class]];
    BOOL loading = NO;
    [[[mockAdsView stub]andReturnValue:OCMOCK_VALUE(loading)] isLoading];
    [[mockAdsView expect] loadRequest:OCMOCK_ANY];
                  
    AdUponController* controller = [[AdUponController new]autorelease];
    controller.customAdView = mockAdsView;
    [controller reload];
    
    [mockAdsView verify];
    
    controller.customAdView = nil;
}

#pragma mark Admob controller test
-(void) testAdmobControllerTest
{
    id mockAdsView = nil;
    @autoreleasepool {
        AdmobAdsController* controller = [[AdmobAdsController new] autorelease];
        id mockController = [OCMockObject partialMockForObject:controller];
        
        mockAdsView = [[OCMockObject mockForClass:[GADBannerView class]]retain];
        [[[mockController stub]andReturn:mockAdsView] createAdmobView: CGRectZero];
        
        id mockCallbackDelegate = [OCMockObject mockForProtocol:@protocol(AdsControllerCallback)];
        
        //on init
        [[mockAdsView expect] setRootViewController:OCMOCK_ANY];
        [[mockAdsView expect] setDelegate:OCMOCK_ANY];
        [[mockAdsView expect] setAdUnitID:OCMOCK_ANY];
        [[mockAdsView expect] loadRequest:OCMOCK_ANY];
        [mockController initWithFrame:CGRectZero andTag:@"test" delegate:mockCallbackDelegate];
        GHAssertEquals(mockCallbackDelegate, [mockController delegate] ,@"");
    
        //on get view
        GHAssertEquals(mockAdsView, [mockController view], @"");
        
        //on reload
        [[mockAdsView expect]loadRequest:OCMOCK_ANY];
        [mockController reload];
        
        //on admob callback
        id mockError = [OCMockObject mockForClass:[GADRequestError class]];
        [[mockError expect]localizedDescription];
        [mockController adView: mockAdsView didFailToReceiveAdWithError:mockError];
        [mockError verify];
        
        [[mockCallbackDelegate expect]adReceived];
        [[mockAdsView expect] disableScrolling];
        [mockController adViewDidReceiveAd:mockAdsView];
        [mockCallbackDelegate verify];
        
        [UIApplication sharedApplication].statusBarHidden = YES;
        [mockController adViewDidDismissScreen:mockAdsView];
        GHAssertFalse([[UIApplication sharedApplication] isStatusBarHidden], @"");
        
        
        //on dealoc       
        [[mockAdsView expect] setRootViewController:nil];
        [[mockAdsView expect] setDelegate:nil];
        
        [mockController verify];
    }
    
    [mockAdsView verify];
    [mockAdsView release];
}

#pragma mark MM controller test
-(void) testMmControllerTest
{
    id mockAdsView = nil;
    @autoreleasepool {
        MillennialController* controller = [[MillennialController new] autorelease];
        id mockController = [OCMockObject partialMockForObject:controller];
        
        mockAdsView = [[OCMockObject mockForClass:[MMAdView class]]retain];
        [[[mockController stub]andReturn:mockAdsView] createMmAds:CGRectZero tag:OCMOCK_ANY];
        
        id mockCallbackDelegate = [OCMockObject mockForProtocol:@protocol(AdsControllerCallback)];
        
        //on init
        [[mockAdsView expect]setRootViewController:mockCallbackDelegate];
        [mockController initWithFrame:CGRectZero andTag:@"test" delegate:mockCallbackDelegate];
        GHAssertEquals(mockCallbackDelegate, [mockController delegate],@"");
        
        //on get view
        GHAssertEquals(mockAdsView, [mockController view],@"");
        
        //on reload
        [[mockAdsView expect]refreshAd];
        [mockController reload];
        
        //callback
        [[mockCallbackDelegate expect] adReceived];
        [[mockAdsView expect]disableScrolling];
        [mockController adRequestSucceeded: mockAdsView];
        
        [mockController adRequestFailed:mockAdsView];
        
        //on dealoc              
        [[mockAdsView expect] setRefreshTimerEnabled:NO];
        [[mockAdsView expect] setDelegate:nil];
        
        [mockController verify];
    }
    
    [mockAdsView verify];
    [mockAdsView release];
}

#pragma mark helpers
-(void)updateConfigsWithFile:(NSString*)name ofType:(NSString*)type
{
    NSDictionary* propertiesDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]];
    [GlobalVariables vars].plist = propertiesDic;
}
@end
