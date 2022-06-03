//
//  AppMakrAnalytics.m
//  appbuildr
//
//  Created by Isaac Mosquera on 5/17/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrAnalytics.h"
#import "MD5.h"
#import "ASIHTTPRequest.h"
#import "AppMakrURLDownload.h"
#import "GlobalVariables.h"
#import "AppMakrOperationQueue.h"
#import "SessionSyncOperation.h"
#import "DownloadLogOperation.h"

#define SUSPEND_DATE_KEY @"LAST_BG_SESSION_END_DATE"
#define DOWNLOAD_KEY @"APPLICATION_WAS_DOWNLOADED"

AppMakrAnalytics *_sharedAnalytics;
const NSString * AM_ANALYTICS_NEW_USER_URI = @"/analytics/log_application_new_user";
const NSString * AM_ANALYTICS_SESSION_URI = @"/analytics/log_application_session";
const NSString * AM_ANALYTICS_DOWNLOAD_URI = @"/analytics/log_application_download";
const NSString * AM_ANALYTICS_MD5_SECRET = @"crizzin";
const NSString * AM_NEW_USER_TRACKED_KEY = @"AM_NEW_USER_TRACKED";


NSDate *lastBgSessionEndDate;

@implementation AppMakrAnalytics

+(AppMakrAnalytics*)sharedAnalytics
{
	@synchronized([AppMakrAnalytics class])
	{
		if (!_sharedAnalytics)
			[[self alloc] init];
        
		return _sharedAnalytics;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([_sharedAnalytics class])
	{
		NSAssert(_sharedAnalytics == nil, @"Attempted to allocate a second instance of a appmakr analytics.");
        _sharedAnalytics = [super alloc];
        
		return _sharedAnalytics;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString *lastSessionDateStr = (NSString *)[userDefaults valueForKey:SUSPEND_DATE_KEY];
        if( lastSessionDateStr ) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
            lastBgSessionEndDate = [[df dateFromString:lastSessionDateStr] retain];
            [df release];
        }
	}
    
	return self;
}

-(void)suspendSession {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    lastBgSessionEndDate = [[NSDate date] retain];
    [userDefaults setValue:[lastBgSessionEndDate description] forKey:SUSPEND_DATE_KEY];
    [userDefaults synchronize];
}
-(void)startSession {
    NSDate *currentDate = [NSDate date];
    if( lastBgSessionEndDate == nil || fabs([lastBgSessionEndDate timeIntervalSinceDate:currentDate]) > 10) {         
         AppMakrOperationQueue *operationQueue = [AppMakrOperationQueue sharedOperationQueue];
         SessionSyncOperation *sessionOp = [[SessionSyncOperation alloc] initWithUniqueID:[currentDate description] ];
         [operationQueue addOperation:sessionOp];
         [sessionOp release];
    }
}

-(void)logDownload
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults boolForKey:DOWNLOAD_KEY])
    {
        AppMakrOperationQueue*operationQueue = [AppMakrOperationQueue sharedOperationQueue];
        DownloadLogOperation* logOperation = [DownloadLogOperation new];
        [operationQueue addOperation:logOperation];
        [logOperation release];
        [userDefaults setBool:YES forKey:DOWNLOAD_KEY];
        [userDefaults synchronize];
    }
}

-(BOOL)applicationStartedForTheFirstTimeAfterInstall
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return ![userDefaults boolForKey:DOWNLOAD_KEY];
}

-(BOOL)wasUpdated
{
    return YES; ///REMOVE THIS FOR 2.26 RELEASE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
}
@end
