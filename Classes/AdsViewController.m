//
//  AdsView.m
//  appbuildr
//
//  Created by PointAbout Dev on 11/6/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "AdsViewController.h"
#import "GlobalVariables.h"
#import "NetworkCheck.h"
#import "NSString+AdUpon.h"
#import "AdUponController.h"
#import "CustomAdsController.h"

@implementation AdsViewController

+(id<AdsController>)createFromGlobalConfiguratinWithTitle:(NSString*) title delegate: (UIViewController<AdsControllerCallback>*) delegate
{	
    if ([AdsViewController isAdsAvailible] && [NetworkCheck hasInternet]) { // if adsDict exists, create a space for the ads and then call AdsView

        NSString * adType = [AdsViewController adType];
        NSString * adTag =  [AdsViewController adTag];
        CGRect adsFrame = CGRectMake(0,0, 320, 50);
        
        if( [adType isEqualToString:@"custom"] ) {		
            NSURL* loadUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"custom_ad_tag" ofType:@"html"]isDirectory:NO];
            return [[[CustomAdsController alloc] initWithFrame:adsFrame andUrl:loadUrl delegate:delegate] autorelease];
        }
        
        if( [adType isEqualToString:@"adupon"]) {		
            NSURL* loadUrl = [NSURL URLWithString:[NSString createAdUponRequestUrl]];
            return [[[AdUponController alloc] initWithFrame:adsFrame andUrl:loadUrl delegate:delegate] autorelease];
        }
	}
    return nil;
}

#pragma mark ads helper
+(NSString*) adType
{
    NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	return [configuration objectForKey:@"ad_type"];
}

+(NSString*) adTag
{
    NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	return [configuration objectForKey:@"ad_tag"];
}

+(BOOL) isAdsAvailible
{
    NSString* adType = [AdsViewController adType];
    NSString* adTag = [AdsViewController adTag];
    return adType && adTag && ![adType isEqualToString:@""] && ![adTag isEqualToString:@""];
}

@end