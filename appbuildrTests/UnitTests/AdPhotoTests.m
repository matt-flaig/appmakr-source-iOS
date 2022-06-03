/*
 * AdPhotoTests.m
 * appbuildr
 *
 * Created on 5/30/12.
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

#import "AdPhotoTests.h"
#import <OCMock/OCMock.h>
#import "AdUponController.h"
#import "GlobalVariables.h"

@interface PhotoAdsDetailView() 
@property(nonatomic, retain) id<AdsController> adManager;
-(void)reloadAds;
-(id<AdsController>)createAdsManager;
-(BOOL)areControlsHidden;
-(void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
-(void)didStartViewingPageAtIndex:(NSUInteger)index;
-(void)invokeSuperWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
@end

@implementation AdPhotoTests

-(void) setUpClass
{
    controller = [PhotoAdsDetailView new];
}

-(void) tearDownClass
{
    [controller release];
}

-(void)setUp
{
    mockController = [[OCMockObject partialMockForObject:controller] retain];
    mockAdsManager = [[OCMockObject mockForProtocol:@protocol(AdsController)] retain];
    [[[mockController expect]andReturn:mockAdsManager] createAdsManager];
    [[[mockAdsManager stub]andReturn:[UIView new]] view];
    
    [mockController viewDidAppear:YES];
}

-(void)tearDown
{
    [mockController verify];
    [mockAdsManager verify];
    
    [mockAdsManager release];
    [mockController release];
}


-(void)testViewDidAppear
{
    UIViewAutoresizing expected  = UIViewAutoresizingFlexibleBottomMargin;
    UIViewAutoresizing actual  = [mockController adManager].view.autoresizingMask;
    GHAssertTrue(expected ==  actual, @"");
}

-(void)testViewDidDisappear
{   
    [[mockAdsManager expect] setDelegate:nil];
    BOOL respond = YES;
    [[[mockAdsManager stub] andReturnValue:OCMOCK_VALUE(respond)] respondsToSelector:@selector(stopLoad)];
    [[mockAdsManager expect] stopLoad];
   
    [mockController viewDidDisappear:YES];    
}

-(void)testRotationPortraitControlsHidden 
{   
    [[mockController expect] reloadAds];
    BOOL visible = YES;
    [[[mockController stub]andReturnValue:OCMOCK_VALUE(visible)]areControlsHidden];
    [[mockController expect]invokeSuperWillAnimateRotationToInterfaceOrientation:UIInterfaceOrientationPortrait duration:1.0];
    
    [mockController willAnimateRotationToInterfaceOrientation: UIInterfaceOrientationPortrait duration:1.0];
    
    int expectedAlpha = 1;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void)testRotationPortraitControlsNotHidden 
{  
    [[mockController expect] reloadAds];  
    BOOL visible = NO;
    [[[mockController stub]andReturnValue:OCMOCK_VALUE(visible)]areControlsHidden];
    [[mockController expect]invokeSuperWillAnimateRotationToInterfaceOrientation:UIInterfaceOrientationPortrait duration:1.0];
    
    [mockController willAnimateRotationToInterfaceOrientation: UIInterfaceOrientationPortrait duration:1.0];
    
    int expectedAlpha = 0;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void)testRotationLandscapeControlsHidden 
{    
    [[mockController expect] reloadAds];
    BOOL visible = YES;
    [[[mockController stub]andReturnValue:OCMOCK_VALUE(visible)]areControlsHidden];
    [[mockController expect]invokeSuperWillAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:1.0];
    
    [mockController willAnimateRotationToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft duration:1.0];
    
    int expectedAlpha = 0;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void)testRotationLandscapeControlsNotHidden 
{
    [[mockController expect] reloadAds];
    BOOL visible = NO;
    [[[mockController stub]andReturnValue:OCMOCK_VALUE(visible)]areControlsHidden];
    [[mockController expect]invokeSuperWillAnimateRotationToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft duration:1.0];
    
    [mockController willAnimateRotationToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft duration:1.0];
    
    int expectedAlpha = 0;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void) testViewDidUnload
{
    [mockController viewDidUnload];
    GHAssertNil([mockController adManager], @"");
}

-(void)testFadeInFadeOutAnimation
{
   [[mockController expect] reloadAds];
    
    UIInterfaceOrientation orintation = UIInterfaceOrientationPortrait;
    [[[mockController expect]andReturnValue:OCMOCK_VALUE(orintation)]interfaceOrientation];
    [mockController setControlsHidden:YES animated:YES permanent:YES];
    
    int expectedAlpha = 1;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void)testFadeOutFadeInAnimation
{
    [[mockController expect] reloadAds];
    
    [mockController setControlsHidden:NO animated:YES permanent:YES];
    
    int expectedAlpha = 0;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
}

-(void)testSwitchPhoto
{
    [[mockController expect]reloadAds];
    [mockController didStartViewingPageAtIndex:0];
}

-(void)testReloadAds
{
    [mockController adManager].view.alpha = 1;
    [[mockAdsManager expect] reload];
    [mockController reloadAds];
}

-(void)testAdReceivedCallbeck
{
    BOOL visible = NO;
    [[[mockController stub]andReturnValue:OCMOCK_VALUE(visible)]areControlsHidden];
    
    [mockController adReceived];

    int expectedAlpha = 0;
    int actualAlpha = [mockController adManager].view.alpha;
    GHAssertEquals(expectedAlpha, actualAlpha, @"");
    
    GHAssertTrue([[mockController view].subviews containsObject: [mockAdsManager view]], @"");
}
@end