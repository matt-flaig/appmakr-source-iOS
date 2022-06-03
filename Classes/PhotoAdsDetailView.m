/*
 * PhotoAdsDetailView.m
 * appbuildr
 *
 * Created on 5/18/12.
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

#import "PhotoAdsDetailView.h"
#import "AdsViewController.h"

@interface MWPhotoBrowser()
    - (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
    - (BOOL)areControlsHidden;
    - (void)didStartViewingPageAtIndex:(NSUInteger)index;
@end

@interface PhotoAdsDetailView() 
    @property(nonatomic, retain) id<AdsController> adManager;

    -(void)reloadAds;
    -(id<AdsController>)createAdsManager;
    -(void)invokeSuperWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
@end

@implementation PhotoAdsDetailView
@synthesize adManager = _adManager;

- (void)dealloc
{
    self.adManager = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

-(id<AdsController>)createAdsManager
{
    return [AdsViewController createFromGlobalConfiguratinWithTitle:self.title delegate:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.adManager = [self createAdsManager];
    self.adManager.view.autoresizingMask  = UIViewAutoresizingFlexibleBottomMargin;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.adManager.delegate = nil;
    if([self.adManager respondsToSelector:@selector(stopLoad)])
        [self.adManager stopLoad];
    [self.adManager.view removeFromSuperview];
}

-(void)invokeSuperWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self invokeSuperWillAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.adManager.view.alpha = [self areControlsHidden] && UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 1:0;    
    [self reloadAds];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.adManager = nil;
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent
{
    [super setControlsHidden:hidden animated:animated permanent:permanent];
    self.adManager.view.alpha  = hidden && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)? 1 : 0;
    [self reloadAds];
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index
{
    [super didStartViewingPageAtIndex: index];
    [self reloadAds];
}

-(void)reloadAds
{
    if(self.adManager.view.alpha == 1) //Reload if ads is visible
        [self.adManager reload];
}

#pragma  mark Ads

-(void)adReceived
{  
    if(self.adManager.view.superview == nil)
    {    
        [self.view addSubview:self.adManager.view];
    }
    self.adManager.view.alpha = [self areControlsHidden] && UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 1 : 0;
}
@end
