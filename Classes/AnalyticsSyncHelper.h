//
//  AnalyticsSyncHelper.h
//  appbuildr
//
//  Created by Isaac Mosquera on 3/25/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnalyticsSyncHelper : NSObject {
 
}
+(NSString *) getSecretKey:(NSString *)udid;
+(NSURL *) getCallUrlWithEndpoint:(const NSString*)endpoint;
@end
