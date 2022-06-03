//
//  DownloadLogOperation.m
//  appbuildr
//
//  Created by Sergey Popenko on 3/4/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "DownloadLogOperation.h"
#import "AppMakrAnalytics.h"
#import "AnalyticsSyncHelper.h"
#import "ASIHTTPRequest.h"

@implementation DownloadLogOperation

-(void) main{
    int retryAttempts = 0;
    while( status != AMOperationStatusSuccess && retryAttempts <= 1 ) {
        retryAttempts++;
        NSURL *url = [AnalyticsSyncHelper getCallUrlWithEndpoint:AM_ANALYTICS_NEW_USER_URI];
        
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
