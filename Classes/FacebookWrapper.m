//
//  FacebookWrapper.m
//  appbuildr
//
//  Created by Fawad Haider  on 1/12/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "FacebookWrapper.h"
#import "GlobalVariables.h"

#define kAPPMakerAPPID @"259197467584" 

@implementation FacebookWrapper

static Facebook* _facebook = nil;



+(Facebook*)facebook{
	@synchronized(self){
	
		if (!_facebook){
			DebugLog(@"getFacebookAppId  ----> %@", [FacebookWrapper getFacebookAppId] );
            _facebook = [[Facebook alloc] initWithAppId:[FacebookWrapper getFacebookAppId]];
		}
		
		return _facebook;
	}
}


+(NSString*)getFacebookAppId{
    NSString* fbAppId = nil;
    
    NSArray* thirdPartyAuths = [[GlobalVariables getPlist] objectForKey:@"third_party_auths"];
    if( thirdPartyAuths ) {
        for(NSDictionary* thirdPartyAuth in thirdPartyAuths) {
            NSDictionary* fields = [thirdPartyAuth objectForKey:@"fields"];
            NSString* company = [fields	objectForKey:@"company"];
            
            if ([company isEqualToString: @"1"]) {//facebook id
                fbAppId =  [fields objectForKey:@"key"];
            }
        }
    }
    else
        fbAppId = kAPPMakerAPPID;
    
    return [[fbAppId copy]autorelease];
}

+(NSString*)getFacebookLocalAppId
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FBSuffix"];
}

- (void)dealloc {
    [super dealloc];
}

@end
