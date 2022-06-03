//
//  DescriptionViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 1/10/09.
//  Copyright 2009 appmakr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


#import "Entry.h"
#import "NetworkCheck.h"
#import "MasterController.h"
#import "AppMakrSocializeCommentsTableViewController.h"
#import "AdsControllerDelegate.h"
#import <Socialize/Socialize.h>

@class AdsViewController;
@class WebpageViewController;

@interface EntryViewController : MasterController<UIWebViewDelegate, 
													MFMailComposeViewControllerDelegate, 
													UINavigationControllerDelegate,
                                                    UIGestureRecognizerDelegate,
                                                    AdsControllerCallback
													> 
{
	//Need there to keep context for entry
    AppMakrSocializeService *currentService;
    Entry				*entry;
		
	id<AdsController> 	adsView;
    SZActionBar  *socializeActionBar;
	
    BOOL				beforeAdLoaded;
    BOOL                contentLoaded;
	
    MFMailComposeViewController          *mailController;   
}

-(id)initWithEntryID:(id)objectID;
-(id)initWithEntryID:(id)objectID service: (AppMakrSocializeService*)service;

@property (nonatomic, retain) IBOutlet id<AdsController> adsView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString* feedBaseUrl;

@end


@interface EntryViewController(Internal)
-(void)initSocialize;
-(void)addMediaPlayerContainer;
-(void)resize;
-(void)resizeWebpage;
-(void)gotoWebpageView:(NSString *) urlString;
-(void)moveActionBarTo: (float)value;
-(void)actionButtonTapped;
-(UIBarButtonItem*) createWebLinkButton;
-(UIWebView*) createWebView;
-(void)sendMailWithUrl: (NSURL*)url;

- (void) adReceivedCallback;
- (NSString *)publisherId;

@property (nonatomic, readonly) WebpageViewController* webpageController;
@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSDictionary* tabConfiguration;
@property (nonatomic, assign) BOOL socializeEnable;

@end