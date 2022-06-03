/*
 * CustomAdsController.m
 * appbuildr
 *
 * Created on 5/23/12.
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

#import "CustomAdsController.h"
#import "UIView+Scrolling.h"

@interface CustomAdsController()
    - (CustomAdView*)createAdsView:(id)delegate frame:(CGRect)frame;
@end

@implementation CustomAdsController
@synthesize customAdView;

-(void)dealloc
{
    [self.customAdView stopLoading];
    self.customAdView.delegate = nil;
    self.customAdView = nil;
    [super dealloc];
}

- (CustomAdView*)createAdsView:(id)delegate frame:(CGRect)frame
{
    return [[[CustomAdView alloc] initWithFrame:frame id:delegate] autorelease];
}

-(id)initWithFrame:(CGRect) frame andUrl:(NSURL*)url delegate: (id<AdsControllerCallback>) delegate
{
    self =  [super init];
    if(self)
    {
        self.customAdView = [self createAdsView:delegate frame:frame];		
		NSURLRequest* customAdRequest = [NSURLRequest requestWithURL:url];
		[self.customAdView loadRequest:customAdRequest];
        [self.customAdView disableScrolling];
    }
    return self;
}

-(void)setDelegate:(id<AdsControllerCallback>)delegate
{
    self.customAdView.proxyDelegate = delegate;
}

-(id<AdsControllerCallback>)delegate
{
    return self.customAdView.proxyDelegate;
}

-(void)reload
{
    if(!self.customAdView.loading)
    {
        [self.customAdView reload];
    }
}

-(void)stopLoad
{
    [self.customAdView stopLoading];
}

-(UIView*)view
{
    return self.customAdView;
}
@end
