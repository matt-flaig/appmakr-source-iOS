//
//  AdsView.h
//  appbuildr
//
//  Created by PointAbout Dev on 11/6/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdsControllerDelegate.h"

@interface AdsViewController : NSObject

+(id<AdsController>)createFromGlobalConfiguratinWithTitle:(NSString*) title delegate: (UIViewController<AdsControllerCallback>*) delegate;

@end

@interface AdsViewController(Helper)
+(NSString*) adType;
+(NSString*) adTag;
+(BOOL) isAdsAvailible;
@end