//
//  FacebookWrapper.h
//  appbuildr
//
//  Created by Fawad Haider  on 1/12/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"



@protocol FacebookWrapperDelegate

-(void)didLogin;
-(void)didNotLogin;

@end


@interface FacebookWrapper : NSObject {
	
	
}

+(Facebook*)facebook;
+(NSString*)getFacebookAppId;
+(NSString*)getFacebookLocalAppId;
@end
