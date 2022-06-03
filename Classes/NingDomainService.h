//
//  NingDomainService.h
//  appbuildr
//
//  Created by William M. Johnson on 9/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "ASIHTTPRequestDelegate.h"
#import "NingDomainServiceDelegate.h"

extern NSString * const NingLoginApi;
extern NSString * const NingAddPhotoApi;
extern NSString * const NingAddBlogPostApi;
extern NSString * const NingUpdateStatusApi;
extern NSString * const NingGetUserInfoApi;


@class OAPointAboutASIFormDataRequest;
@interface NingDomainService : NSObject <ASIHTTPRequestDelegate> 
{
	OAConsumer *consumer;
    OAToken *accessToken;
	NSString * author;
	id<NingDomainServiceDelegate> delegate;
	
	OAPointAboutASIFormDataRequest *request;

	
	NSString * subDomainName;

}

@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, retain) OAToken *accessToken;
@property (readonly) BOOL userIsLoggedin;
@property (nonatomic, assign) id<NingDomainServiceDelegate> delegate;
@property (nonatomic, readonly) NSString * registrationUrlString;

-(void) logout;
-(void) cancelRequest;
-(void) loginWithUsername:(NSString *) username password:(NSString *) password;
-(void) addPhoto:(UIImage *) photo title:(NSString *) photoTitle description:(NSString*) photoDescription;
-(void) addBlogPost:(NSString*) blogPostContents title:(NSString *) blogPostTitle;
-(void) updateStatus:(NSString *)statusMessage;
-(void) getUserInformation;

@end
