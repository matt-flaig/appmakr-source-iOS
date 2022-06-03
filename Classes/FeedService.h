//
//  FeedService.h
//  appbuildr
//
//  Created by William Johnson on 10/18/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAPointAboutASIFormDataRequest.h"
#import "DataStore.h"
#import "CHReadWriteLock.h"

#define serviceProviderName @"SOCIALIZE"
#define socializeUserKey @"socialize_current_user_id"

extern NSString * const kSocializeConsumerKeyKey;
extern NSString * const kSocializeConsumerSecretKey;
extern NSString * kSocializeApiURL;
extern NSString * kSocializeApiVersion;


@class Entry;
@class Feed;
@protocol FeedServiceDelegate;

extern int maxStories;

@interface FeedService : NSObject <ASIHTTPRequestDelegate> 
{
   id<FeedServiceDelegate> delegate;
	
	
	NSMutableSet *outstandingRequests;
	NSRecursiveLock *cancelledLock;
    CHReadWriteLock* updateEntyLock;
	DataStore * localDataStore;
    
    OAConsumer *consumer;
    OAToken	   *accessToken;
}
@property (nonatomic, retain) OAConsumer	*consumer;
@property (nonatomic, retain) OAToken		*accessToken;

@property (nonatomic, assign) id<FeedServiceDelegate> delegate;
@property (retain) NSRecursiveLock *cancelledLock;
@property (nonatomic, retain) DataStore * localDataStore;

-(NSString *) fullSocializeApiURLString:(NSString *)api;
-(NSString *)fullURLStringforApi:(NSString *)api withQueryParameter:(NSString*)parameter;
-(NSURL *)fullURLforApi:(NSString *)api;
-(NSURL *)fullURLforApi:(NSString *)api withQueryParameter:(NSString*)parameter;
-(NSURL *)fullURLforApi:(NSString *)api forEntryUrl:(NSString*)entryUrl;

-(Feed *)fetchFeedFromCacheWithKey:(NSString*)feedKey;

-(void)fetchFeedFromUrl:(NSURL *)feedUrl saveWithKeyValue:(NSString *)feedKey AndType:(NSString *)type;
-(void)fetchFullSizedImageForEntry:(Entry *) entry;
-(void)fetchThumbnailForEntry:(Entry*)entry;
-(void)cancelAllFetchRequests;

//Request creation and destroy methos NOTE:This should be a private category
-(ASIFormDataRequest *)createNewRequestForURL:(NSURL *)requestURL;  //Template method for creating requests.
-(void)destroyRequest:(ASIHTTPRequest *)request;                    //Template method for destroying requests.
-(ASIFormDataRequest *)doCreateRequestForURL:(NSURL *)requestURL;   //primitive method for creating requests.
-(void)doDestroyRequest:(ASIHTTPRequest *)request;                  //primitive method for destroying requests.
-(void)startRequest:(ASIHTTPRequest *)request;
-(OAPointAboutASIFormDataRequest * )createNewOAuthRequestForURL:(NSURL *)requestURL;

//for unit test
-(NSString *)getQueryURLForEntryFullSizedImage:(NSString *)entryFullSizedImageUrl;
-(NSString *)getQueryURLForEntryThumbnail:(NSString *)entryThumbnailUrl;

@end


@protocol FeedServiceDelegate<NSObject>

@optional
-(void) feedService:(FeedService *)feedService didStartFetchingFeedForUrl:(NSURL *)feedUrl;
-(void) feedService:(FeedService *)feedService didFetchFeed:(Feed *)feed;
-(void) feedService:(FeedService *)feedService didFailFetchingFeedWithError:(NSError *)error;
-(void) feedServiceDidFinishFetchingFeed:(FeedService *)feedService;

-(void) feedService:(FeedService *)feedService didFinishFetchingThumbnailForEntry:(Entry *)entry;
-(void) feedService:(FeedService *)feedService didFetchFullSizedImageForEntry:(Entry *)entry;
-(void) feedService:(FeedService *)feedService didFailFetchingFullSizedImageWithError:(NSError *)error;
-(void) feedServiceDidFinishFetchingFullSizedImage:(FeedService *)feedService;

@end