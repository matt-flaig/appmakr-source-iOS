//
//  ModuleFactory.m
//  appbuildr
//
//  Created by Nitin Alabur on 12/2/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ModuleFactory.h"
#import "PointAboutTabBarScrollViewController.h"
#import "FeedTableViewController.h"
#import "PhotoThumbnailController.h"
#import "NingProfileViewController.h"
#import "GeoFeedTableViewController.h"
#import "MessageViewController.h"
#import "SendMessageViewController.h"
#import "EmailViewController.h"
#import "GlobalVariables.h"
#import "HtmlViewController.h"
#import <PhoneGap/PGViewController.h>
#import "SVWebViewController.h"
#import "VideoThumbnailController.h"

NSString *  const moduleTypeGeoRss  = @"georss";
NSString *  const moduleTypeAlbum   = @"album";
NSString *  const moduleTypeVideo   = @"video";
NSString *	const moduleTypeRss     = @"rss";
NSString *  const moduleTypeHTML    = @"html";
NSString *  const moduleTypeNing    = @"ning";
NSString *  const moduleTypeMessage = @"message";
NSString *  const moduleTypeWeb = @"web";

static ModuleIndexPath* currentModulePath = nil;

@implementation ModuleFactory

+ (UIViewController*)getViewControllerForModule:(NSDictionary *)module {
    NSDictionary *fields = [module objectForKey:@"fields"];
	NSString* type = [fields objectForKey:@"type"];
	
	//the following is done because the webside doesn't set the type
	//as twotier, it keeps it as rss. so we have to override the type and set it as twotier.
	NSArray *children = [[module objectForKey:@"extras"]objectForKey:@"children"];
	if(children && [children count] > 0) {
		type = @"twotier";
	}
	NSString *selectorString = [NSString stringWithFormat:@"%@ViewControllerFor:", type];
	SEL selector = NSSelectorFromString(selectorString);
	if ([self respondsToSelector:selector]) {
		return [self performSelector:selector withObject:module];
  	}
	return nil;
}

+(UIViewController *)getViewControllerForModule:(NSDictionary *)module atIndex:(int)index{
    
    currentModulePath = [ModuleIndexPath createWithIndex:[NSNumber numberWithInt:index] childIndex:nil];
    
    UIViewController* controller = [self getViewControllerForModule:module];
    if([controller isKindOfClass:[MasterController class]])
        ((MasterController*)controller).modulePath = currentModulePath;
    
    return controller;

}

+(UIViewController *)twotierViewControllerFor:(NSDictionary *)module{
	//NSDictionary *fields = [module objectForKey:@"fields"];
	NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithCapacity:2];	
	NSArray *secondTierModules = [[module objectForKey:@"extras"]objectForKey:@"children"];
	
	NSDictionary *configuration = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	CGFloat bgRed = [(NSNumber *)[configuration objectForKey:@"header_bg_red"] floatValue]/255.0f;
	CGFloat bgGreen =[(NSNumber *)[configuration objectForKey:@"header_bg_green"] floatValue]/255.0f;
	CGFloat bgBlue = [(NSNumber *)[configuration objectForKey:@"header_bg_blue"] floatValue]/255.0f;

	for (NSDictionary *tierModule in secondTierModules) {

		UIViewController *rootViewController = [self getViewControllerForModule:tierModule];
        if([rootViewController isKindOfClass:[MasterController class]])
        {
            ((MasterController*)rootViewController).modulePath =  [ModuleIndexPath createWithIndex:currentModulePath.moduleIndex childIndex:[NSNumber numberWithInt:[secondTierModules indexOfObject:tierModule]]];
        }
        
		[viewControllerArray addObject:rootViewController];
		
	}
	
	PointAboutTabBarScrollViewController *paTabBarScrollViewController = [[PointAboutTabBarScrollViewController alloc] 
																		  initWithViewControllers:viewControllerArray
																		  displayType:POINTABOUT_TABBAR_DISPLAY_TEXT
																		  displayTop:YES];
	
	paTabBarScrollViewController.tabBarBackgroundColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0];
    paTabBarScrollViewController.title = [self tabTitle:module];
	
	[viewControllerArray release];	
	return paTabBarScrollViewController;
}

+(UIViewController *)rssViewControllerFor:(NSDictionary *)module{
	FeedTableViewController *rssViewController = [[[FeedTableViewController alloc] initWithFeed:[self feedUrl:module] title:[self tabTitle:module]] autorelease];	
	rssViewController.moduleType = moduleTypeRss;
	return rssViewController;
}

+(UIViewController *)webViewControllerFor:(NSDictionary *)module{
    SVWebViewController *webViewController = [[[SVWebViewController alloc] initWithAddress:[self feedUrl:module]] autorelease];    
	return webViewController;
}

+(UIViewController *)georssViewControllerFor:(NSDictionary *)module{
	GeoFeedTableViewController *georssViewController = [[[GeoFeedTableViewController alloc] initWithFeed:[self feedUrl:module] title:[self tabTitle:module]] autorelease];	
	georssViewController.moduleType = moduleTypeGeoRss;
	return georssViewController;
}

+(UIViewController *)albumViewControllerFor:(NSDictionary *)module{
	PhotoThumbnailController *photoViewController = [[[PhotoThumbnailController alloc] initWithFeedURL:[self feedUrl:module] title:[self tabTitle:module]] autorelease];
	photoViewController.moduleType = moduleTypeAlbum;
	return photoViewController;
}

+(UIViewController *)videoViewControllerFor:(NSDictionary *)module{
	VideoThumbnailController *videoViewController = [[[VideoThumbnailController alloc] initWithFeedURL:[self feedUrl:module] title:[self tabTitle:module]] autorelease];
	videoViewController.moduleType = moduleTypeVideo;
	return videoViewController;
}

+(UIViewController *)messageViewControllerFor:(NSDictionary *)module{
	NSDictionary *fields = [module objectForKey:@"fields"];
	NSDictionary *moduleSettings = (NSDictionary *)[fields objectForKey:@"settings"];
	NSDictionary *settingsFields = (NSDictionary *)[moduleSettings objectForKey:@"fields"];
	
	
	BOOL includeLocation = [[settingsFields objectForKey:@"include_location"] boolValue];
	
	
	BOOL encryptionKeyIsSet = [[[NSUserDefaults standardUserDefaults] objectForKey:@"encryption_key_set"]boolValue];
	
	NSDictionary * settings = [fields objectForKey:@"settings"];
	BOOL isEmailMessage = NO;
	if (settings) 
	{
		NSDictionary * messageFields = [settings objectForKey:@"fields"];
		if (messageFields) 
		{
			NSString * method = [messageFields objectForKey:@"method"];
            isEmailMessage = [method isEqualToString:@"email"];
		}
	}
	NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	BOOL useEncryption = [[configuration objectForKey:@"encryption"]boolValue];
	if (!useEncryption || (useEncryption && encryptionKeyIsSet)) 
	{
		MessageViewController * messageVC = nil;
		if (!isEmailMessage) //Put check for message type here
		{
			messageVC = [[[SendMessageViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		}
		else 
		{
			messageVC = [[[EmailViewController alloc] initWithNibName:nil bundle:nil] autorelease];
			//Pass-in settings to the module or put in NSUserDefaults. 
		}
		messageVC.useEncryption = useEncryption;
		messageVC.includeLocation = includeLocation;
		messageVC.moduleType = moduleTypeMessage;
		return messageVC;
	}
	return nil;



}
+(UIViewController *)htmlViewControllerFor:(NSDictionary *)module{   
    HtmlViewController* viewController = [[[HtmlViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    viewController.moduleType = moduleTypeHTML;
    viewController.pageName = [self tabTitle:module];
    return viewController;
}
+(UIViewController *)ningViewControllerFor:(NSDictionary *)module{
	NSDictionary *fields = [module objectForKey:@"fields"];
	NSDictionary *moduleSettings = (NSDictionary *)[fields objectForKey:@"settings"];
	NSDictionary *settingsFields = (NSDictionary *)[moduleSettings objectForKey:@"fields"];
	
	NSString * ningConsumerKey = [settingsFields objectForKey:@"key"];
	ningConsumerKey = [ningConsumerKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSString * ningConsumerSecret = [settingsFields objectForKey:@"secret"];
	ningConsumerSecret =[ningConsumerSecret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:ningConsumerKey forKey:@"NING_CONSUMER_KEY"];
	[defaults setObject:ningConsumerSecret forKey:@"NING_CONSUMER_SECRET"];
	[defaults setObject:[self feedUrl:module] forKey:@"NING_SUBDOMAIN"];
	
	NingProfileViewController *profileViewController = [[[NingProfileViewController alloc] init] autorelease];
	profileViewController.title = [self tabTitle:module];
	profileViewController.moduleType = moduleTypeNing;

	
	return profileViewController;
}

+(NSString *)feedUrl:(NSDictionary *)module{
	NSDictionary *fields = [module objectForKey:@"fields"];
	NSString* feedUrl = [fields objectForKey:@"url"];
	return feedUrl;
}

+(NSString *)tabTitle:(NSDictionary *)module{
	NSDictionary *fields = [module objectForKey:@"fields"];
	NSString* tabTitle = [fields objectForKey:@"name"];
	return tabTitle;
}
@end
	