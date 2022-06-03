//
//  SessionSyncOperation.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/23/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "SessionSyncOperation.h"
#import "GlobalVariables.h"
#import "MD5.h"
#import "ASIHTTPRequest.h"
#import "AnalyticsSyncHelper.h"

@implementation SessionSyncOperation

-(void) main{
    int retryAttempts = 0;
    while( status != AMOperationStatusSuccess && retryAttempts <= 1 ) {
        retryAttempts++;

        NSURL *url = [AnalyticsSyncHelper getCallUrlWithEndpoint:AM_ANALYTICS_SESSION_URI];

        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request startSynchronous];
        NSError *error = [request error];
        if (error) {
            DebugLog(@"###### status failed! %@", [request responseString] );
            status = AMOperationStatusFailed;
        } else {
            DebugLog(@"###### the return response from session is %@", [request responseString] );
            NSString *response = [request responseString];
            if ([response isEqualToString:@"OK"]) { 
                status = AMOperationStatusSuccess;
            } else {
                status = AMOperationStatusFailed;
            }        
        }
        if( status == AMOperationStatusFailed ) {
            DebugLog(@"#### sleeping for 10 seconds");
            [NSThread sleepForTimeInterval:10];
        }   
    }
}
@end
