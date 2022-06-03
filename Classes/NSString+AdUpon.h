//
//  NSString+AdUpon.h
//  appbuildr
//
//  Created by Sergey Popenko on 1/30/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalVariables.h"
#import <CoreLocation/CoreLocation.h>

@interface NSString (AdUpon)

+(NSString*)createAdUponRequestUrlWithLocation: (CLLocation*)location;
+(NSString*)createAdUponRequestUrl;
@end
