/*
 * AboutPageViewController.m
 * appbuildr
 *
 * Created on 5/21/12.
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

#import "AboutPageViewController.h"
#import "CustomNavigationBar.h"
#import "GlobalVariables.h"
#import "MBProgressHUD.h"
#import <Socialize/Socialize.h>

@interface AboutPageViewController()
{
    BOOL contentWasLoad;
}

@property (nonatomic, retain) UIWebView* aboutPageView;
@property (nonatomic, retain) SZActionBar* sszBar;
@property (nonatomic, retain) MBProgressHUD* progress;
@end

@implementation AboutPageViewController
@synthesize aboutPageView = _aboutPageView;
@synthesize sszBar = _sszBar;
@synthesize progress = _progress;

- (void)dealloc
{
    self.aboutPageView = nil;
    self.sszBar = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup background navigation image
    UIImage* headerImage = [UIImage imageNamed:@"header_image.png"];
    if(headerImage && [self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
        [((CustomNavigationBar*)self.navigationController.navigationBar) setBackgroundWith:headerImage];
    
    //setup dismiss button
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeBtn setBackgroundImage:[UIImage imageNamed:@"nav_btn_home.png"] forState:UIControlStateNormal];
    [homeBtn setFrame:CGRectMake(0, 0, 41, 33)];
    [homeBtn addTarget:self action:@selector(dismiss)forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:homeBtn] autorelease];
    
    //add socialize action bar
    if ([GlobalVariables aboutPageUrl] && [GlobalVariables socializeEnable]){
        self.sszBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:[SZEntity entityWithKey:[GlobalVariables aboutPageUrl] name:[GlobalVariables appName]] viewController:self];
        [self.view addSubview:self.sszBar];
    }
    
    //prepare main web view
    UIWebView* aboutPageView = [[UIWebView alloc] init];
    aboutPageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    aboutPageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.sszBar.frame.size.height);
    aboutPageView.delegate = self;
    aboutPageView.scalesPageToFit = YES;
    aboutPageView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.view addSubview:aboutPageView];
    self.aboutPageView = aboutPageView;
    [aboutPageView release];
    
    //setup class members
    contentWasLoad = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.aboutPageView = nil;
    self.sszBar = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.aboutPageView.loading && !contentWasLoad)
    {
        NSURLRequest* aboutPageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[GlobalVariables aboutPageUrl]]];
        [self.aboutPageView loadRequest:aboutPageRequest];
        
        self.progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	    
        self.progress.dimBackground = YES;
        self.progress.labelText = @"Loading";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.aboutPageView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dismiss
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma UIWebView delegate handlers
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{
	if( navigationType == UIWebViewNavigationTypeLinkClicked ||  navigationType == UIWebViewNavigationTypeFormSubmitted ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    contentWasLoad = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Load error occured %@", [error localizedDescription]);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
@end
