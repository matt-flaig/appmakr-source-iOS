//
//  NetworkCheck.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NetworkCheck.h"
#import "Reachability.h"

@implementation NetworkCheck
BOOL hasShowedMessage = NO;

+ (BOOL)hasInternet {
	NetworkStatus internetConnectionStatus	= [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	if ( internetConnectionStatus == NotReachable ) {
		if( !hasShowedMessage) {
			hasShowedMessage = YES;
			NSString *hostNotReachable = 
			[[NSString alloc] initWithFormat: @"Unable to download new content because your iphone does not have connectivity to the Internet.\n\nPlease retry when you establish connectivity."]; 
			UIAlertView *uiAlert = [[UIAlertView alloc]
									initWithTitle:@"http error" message:hostNotReachable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[uiAlert show]; 
			[uiAlert release];
			[hostNotReachable release];
		}
		return NO;
	} else {
		return YES;
	}
}

+ (BOOL)hasWiFi{
	NetworkStatus networkIsWiFi	= [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	if ( networkIsWiFi ==  ReachableViaWiFi) {
		return YES;
	} else {
		return NO;
	}
}

@end
