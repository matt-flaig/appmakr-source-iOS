//
//  NSString+AdUpon.m
//  appbuildr
//
//  Created by Sergey Popenko on 1/30/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "NSString+AdUpon.h"
#import "AppMakrNativeLocation.h"

#define NETWORK_ID 2
#define SITE_ID 101

@implementation NSString (AdUpon)
+(NSString*)createAdUponRequestUrlWithLocation:(CLLocation*)location
{
    //http://adproxy.mobi/mproxy/f/2/101/102/w.320/h.50/d.483a269b72ab8bc5d4a5fe0659c90f4808ce615b/rn/app.Test/aid.10011/lt.0/lg.0

    CFUUIDRef cfuuid = CFUUIDCreate(NULL);
    NSString *uuid =  (NSString *)CFUUIDCreateString(NULL, cfuuid);
    CFRelease(cfuuid);
    NSMutableString* url = [NSMutableString stringWithFormat:@"http://adproxy.mobi/mproxy/f/%d/%d/%d/w.320/h.50/d.%@/rn/app.%@/aid.%d", NETWORK_ID, SITE_ID, [[GlobalVariables appID]intValue],uuid, [GlobalVariables appName], [[GlobalVariables appID]intValue]];
    
    if(location)
        [url appendFormat:@"/lt.%f/lg.%f",location.coordinate.latitude, location.coordinate.longitude];
        
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString*)createAdUponRequestUrl
{
    CLLocation* location = nil;
    AppMakrNativeLocation* locationManager = [AppMakrNativeLocation sharedInstance];
    if(locationManager.started)
    {
        location = locationManager.lastKnownLocation;
    }
    else
    {
        [locationManager start];
    }
    
    return [self createAdUponRequestUrlWithLocation:location];
}
@end
