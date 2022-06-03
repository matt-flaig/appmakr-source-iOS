//
//  NetworkCheck.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkCheck : NSObject {

}
+ (BOOL)hasInternet;
+ (BOOL)hasWiFi;
@end
