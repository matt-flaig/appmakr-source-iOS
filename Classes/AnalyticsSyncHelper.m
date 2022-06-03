//
//  AnalyticsSyncHelper.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/25/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AnalyticsSyncHelper.h"
#import "GlobalVariables.h"
#import "AppMakrAnalytics.h"
#import "MD5.h"

#import "GlobalVariables.h"

@implementation AnalyticsSyncHelper

+(NSString *) getSecretKey:(NSString *)udid {
    NSString * stringToMD5 = [NSString stringWithFormat:@"%@%@%@", AM_ANALYTICS_MD5_SECRET, udid,[GlobalVariables appID]];
    NSString * key = [MD5 hash:stringToMD5];
    return key;
}

NSString *UUID() {
    CFUUIDRef cfuuid = CFUUIDCreate(NULL);
    NSString *uuid =  (NSString *)CFUUIDCreateString(NULL, cfuuid);
    CFRelease(cfuuid);
    return uuid;
}

+(NSURL *) getCallUrlWithEndpoint:(const NSString*)endpoint
{
    NSString * uuid = UUID();
    NSString * key = [AnalyticsSyncHelper getSecretKey:uuid];

    
    NSString * absoluteURL = [NSString stringWithFormat:@"%@%@?uuid=%@&app=%@&build=%@&k=%@",
                              [GlobalVariables appmakrHost], endpoint, uuid, [GlobalVariables appID],
                              [GlobalVariables buildID], key];
    NSURL *url = [NSURL URLWithString:absoluteURL];
    return url;
}
@end
