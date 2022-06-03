//
//  InternetDependencyOperation.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/23/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "NetworkReadyOperation.h"
#import "Reachability.h"

#define NEXT_CHECK_TIME 10
@implementation NetworkReadyOperation

-(void)main {
    
    DebugLog(@"checking the network...");
    while ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable){
        DebugLog(@"### sleeping for 10 seconds while waiting for internet");
        [NSThread sleepForTimeInterval:NEXT_CHECK_TIME];
    } 
    DebugLog(@"finally got internet!");
}
@end
