//
//  GlobalVariables+Twitter.m
//  appbuildr
//
//  Created by Sergey Popenko on 19.03.12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "GlobalVariables+Twitter.h"

#define kTwitterOAuthConsumerKey	@"ZowAkTXBa5qQZblCxZyvg"
#define kTwitterOAuthConsumerSecret	@"TNjoWmyItMsObxZrz0x4rOBsekTEksY1fIwxKD0QM"

#define kCompanyTwitter @"2"


@implementation GlobalVariables (Twitter)

+(NSPair*)twitterApiKeySecret
{
    NSPair* twitterApi = [NSPair new];
    
    NSArray* thirdPartyAuths = [[GlobalVariables getPlist] objectForKey:@"third_party_auths"];
    
    if( thirdPartyAuths ) {
        for(NSDictionary* thirdPartyAuth in thirdPartyAuths) {
            NSDictionary* fields = [thirdPartyAuth objectForKey:@"fields"];
            NSString* company = [fields	objectForKey:@"company"];
            
            if ([company isEqualToString: kCompanyTwitter]) {
                twitterApi.first =  [[fields objectForKey:@"key"] retain];
                twitterApi.second = [[fields objectForKey:@"secret"] retain];
            }
        }
    }
    
    if (!twitterApi.first || !twitterApi.second ) {
        twitterApi.first  = kTwitterOAuthConsumerKey;
        twitterApi.second  = kTwitterOAuthConsumerSecret;
    }
    return  [twitterApi autorelease];
}
@end
