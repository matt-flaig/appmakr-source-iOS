//
//  AppMakrAnalytics.h
//  appbuildr
//
//  Created by Isaac Mosquera on 5/17/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrURLDownload.h"
#import "DataStore.h"

extern const NSString * AM_ANALYTICS_NEW_USER_URI;
extern const NSString * AM_ANALYTICS_SESSION_URI;
extern const NSString * AM_ANALYTICS_MD5_SECRET;
extern const NSString * AM_ANALYTICS_DOWNLOAD_URI;

const NSString * AM_NEW_USER_TRACKED_KEY;
@interface AppMakrAnalytics : NSObject {
    //the following will most likely be used when we have more
    //session data.
    /*DataStore *localDataStore; */
}
+(AppMakrAnalytics*)sharedAnalytics;
-(void)startSession;
-(void)suspendSession;
-(void)logDownload;
-(BOOL)applicationStartedForTheFirstTimeAfterInstall;
-(BOOL)wasUpdated;
@end
