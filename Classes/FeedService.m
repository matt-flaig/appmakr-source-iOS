//
//  FeedService.m
//  appbuildr
//
//  Created by William Johnson on 10/18/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "FeedService.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "FeedParser.h"
#import "FeedArchiver.h"
#import "Feed.h"
#import "Feed+Extensions.h"
#import "EntryImageReference.h"
#import "ImageReference+Extensions.h"
#import "Entry.h"
#import "Link.h"
#import "DataStore.h"
#import "GlobalVariables.h"
#import "NSPredicate+Creation.h"
#import "MD5.h"
#import "OAPointAboutASIFormDataRequest.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "GlobalVariables.h"
#import "GTMNSString+HTML.h"

NSString * const kSocializeConsumerKeyKey = @"socialize_consumer_key";
NSString * const kSocializeConsumerSecretKey = @"socialize_consumer_secret";
NSString * kSocializeApiURL = nil;
NSString * kSocializeApiVersion = nil;

static NSString * const FS_REQUEST_URL_KEY		 =	@"FS_REQUEST_URL_KEY";
static NSString * const FS_REQUEST_TYPE_KEY      =  @"FS_REQUEST_TYPE_KEY";
static NSString * const FS_ENTRY_THUMBNAIL_KEY	 =  @"FS_REQUEST_THUMBNAIL_KEY";
static NSString * const FS_RQTYPE_FEED           =  @"FS_FEED";
static NSString * const FS_RQTYPE_THUMNAIL       =  @"FS_THUMBNAIL";
static NSString * const FS_RQTYPE_FULLSIZEDIMAGE =  @"FS_IMAGE";


static ASINetworkQueue *sharedQueue = nil;  //Probably doesn't need to be static.


int maxStories;

@interface FeedService()
- (ASIFormDataRequest *)createNewRequestForURL:(NSURL *)requestURL;
- (void)destroyRequest:(ASIHTTPRequest *)request;
- (void)addToOutstandingRequests:(ASIHTTPRequest *)request;
- (void)removeFromOutstandingRequests:(ASIHTTPRequest *)request;
@property(assign,atomic) BOOL canceled;

@end


@implementation FeedService

@synthesize consumer;
@synthesize accessToken;
@synthesize delegate;
@synthesize cancelledLock;
@synthesize localDataStore;
@synthesize canceled;

static BOOL initialized = NO;
+ (void)initialize
{

    if (self != [FeedService class] || initialized)
        return;
	
	NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	maxStories = [[configuration objectForKey:@"max_stories"] intValue];
	
	if(!maxStories)
		maxStories = 100;
	
	sharedQueue = [[ASINetworkQueue alloc] init];
	sharedQueue.shouldCancelAllRequestsOnFailure = NO;
	[sharedQueue setMaxConcurrentOperationCount:2];
	[sharedQueue go];
    
    NSDictionary * application = (NSDictionary * )[global objectForKey:@"application"];
	
	NSString * socializeConsumerKey = [application objectForKey:kSocializeConsumerKeyKey];
	socializeConsumerKey = [socializeConsumerKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //NSLog(@"UDID", )
    
	NSString * socializeConsumerSecret = [application objectForKey:kSocializeConsumerSecretKey];
	socializeConsumerSecret =[socializeConsumerSecret stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setObject:socializeConsumerKey forKey:kSocializeConsumerKeyKey];
	[defaults setObject:socializeConsumerSecret forKey:kSocializeConsumerSecretKey];
	
	
	
	kSocializeApiURL     =   [[global valueForKey:@"socialize_api_url"] retain];
	kSocializeApiVersion =   [[global valueForKey:@"socialize_api_version"]retain];
    
    initialized = YES;
	
}

- (id)init 
{
	
	if ((self = [super init])) 
	{
		outstandingRequests = [[NSMutableSet setWithCapacity:10] retain];
		cancelledLock = [[NSRecursiveLock alloc] init];
        updateEntyLock = [[CHReadWriteLock sharedLock] retain];
		
		localDataStore = [[DataStore alloc]init];
		
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		
		NSString * socializeConsumerKey =    (NSString *)[defaults valueForKey:kSocializeConsumerKeyKey];
		NSString * socializeConsumerSecret = (NSString *)[defaults valueForKey:kSocializeConsumerSecretKey];
		
		NSAssert((socializeConsumerKey!=nil&& ([socializeConsumerKey length]>0)), @"Invalid consumer key");
		NSAssert((socializeConsumerSecret!=nil&& ([socializeConsumerSecret length]>0)), @"Invalid consumer secret");
		
		consumer = [[OAConsumer alloc]initWithKey:socializeConsumerKey secret:socializeConsumerSecret];
		
        //fix memory allocation in initWithUserDefaultsUsingServiceProviderName method
        //http://code.google.com/p/oauth/source/browse/code/obj-c/OAuthConsumer/OAToken.m?r=829
        NSString *theKey = [[NSUserDefaults standardUserDefaults] stringForKey:
                            [NSString stringWithFormat:@"OAUTH_%@_%@_KEY", serviceProviderName, serviceProviderName]];
        NSString *theSecret = [[NSUserDefaults standardUserDefaults] stringForKey:
                               [NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", serviceProviderName, serviceProviderName]];
        if (theKey != NULL || theSecret != NULL)
        {
            accessToken = [[OAToken alloc] initWithKey:theKey secret:theSecret];
        }
	}
	
	return self;
}

-(void)cancelAllFetchRequests
{
	   [[self cancelledLock] lock];
			[[outstandingRequests allObjects] makeObjectsPerformSelector:@selector(cancel)];	
            self.canceled = YES;
		[[self cancelledLock] unlock];

}

- (void) dealloc
{
	self.delegate = nil;
	
	//May want to do something like the following.
	//OPTION1: However, this may not execute fast enough
	//[outstandingRequests makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
//	[outstandingRequests makeObjectsPerformSelector:@selector(cancel)];
	DebugLog(@"Canceling requests");
	[self cancelAllFetchRequests];
	DebugLog(@"All request have been canceled.");
	//OPTION2: Get access to ASI's Queue and stop the operations. NOTE: I don't see a way to do that.
	//OPTION 2.5:  Put the operations in our own queue and then stop them from the queue.
	
	//OPTION3:
	//Create a method that explicity stops the ASIoperations.
	
	
	[outstandingRequests release], outstandingRequests = nil;
	
	[cancelledLock release]; cancelledLock =nil;
    [updateEntyLock release]; updateEntyLock = nil;

	DebugLog(@"#### WE ARE IN DEALLOC %@", localDataStore);
	[localDataStore release]; localDataStore =nil;
	DebugLog(@"THIS OBJECT HAS BEEN DALLOC");

	[consumer release];
	[accessToken release];

	[super dealloc];
	
}

-(NSString *) fullSocializeApiURLString:(NSString *)api
{
	NSString * fullURLString = nil;
	
	if ((kSocializeApiVersion != nil) && ([kSocializeApiVersion length] > 0))
	{
		fullURLString = [NSString stringWithFormat:@"%@/%@/%@/", kSocializeApiURL,kSocializeApiVersion, api];
        return fullURLString;
	}
	
	//TEST SEVERE <<<!!!>>>
	fullURLString = [NSString stringWithFormat:@"%@/%@/", kSocializeApiURL,api];
    //fullURLString = [NSString stringWithFormat:@"%@/%@/", @"http://192.168.199.208:8000", api];
	
	return fullURLString;
}
-(NSURL *)fullURLforApi:(NSString *)api
{
	
	NSString * fullURLString = [self fullSocializeApiURLString:api];
	return [NSURL URLWithString:fullURLString];
}

-(NSString *)fullURLStringforApi:(NSString *)api withQueryParameter:(NSString*)parameter {
    //NSString * fullURLString = [self fullSocializeApiURLString:api];
    //NOTE: temporary fix until problem with images download, later move to url format
    NSString * fullURLString = [[self fullSocializeApiURLString:api] gtm_stringByUnescapingFromHTML];
    
	//This implementation needs to change.  Need to check for valid key-value pair.
	if (parameter !=nil && [parameter length] > 0) 
	{
		//fullURLString = [NSString stringWithFormat:@"%@?%@",fullURLString, parameter];
        //NOTE: temporary fix until problem with images download, later move to url format
		fullURLString = [[NSString stringWithFormat:@"%@?%@",fullURLString, parameter] gtm_stringByUnescapingFromHTML];
	}
    
    return fullURLString;
}

-(NSURL *)fullURLforApi:(NSString *)api withQueryParameter:(NSString*)parameter
{
	NSString *fullURLString = [self fullURLStringforApi:api withQueryParameter:parameter];
	return [NSURL URLWithString:fullURLString];
}

-(NSURL *)fullURLforApi:(NSString *)api forEntryUrl:(NSString*)entryUrl
{
    //return [self fullURLforApi:api withQueryParameter:[NSString stringWithFormat:@"url=%@", entryUrl]];
    //NOTE: temporary fix until problem with images download, later move to url format
    return [self fullURLforApi:api withQueryParameter:[NSString stringWithFormat:@"url=%@", [entryUrl gtm_stringByUnescapingFromHTML]]];
    //
}


-(Feed *)fetchFeedFromCacheWithKey:(NSString*)feedKey
{
	Feed * feed = (Feed *) [localDataStore retrieveSingleEntityForClass:[Feed class] withValue:feedKey forAttribute:@"key"];
	return feed;
	
}
-(void)fetchFeedFromUrl:(NSURL *)feedUrl saveWithKeyValue:(NSString *)feedKey AndType:(NSString *)type
{
	
	NSString * feedUrlString = [feedUrl absoluteString];
	
	NSAssert([feedUrlString length] > 3,@"Invalid URL for feed. Feed URL cannot be null or empty.");
	
    [self cancelAllFetchRequests];
	ASIFormDataRequest * request = [self createNewRequestForURL:feedUrl];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
	[userInfoDictionary setValue:feedUrlString forKey:FS_REQUEST_URL_KEY];
	
	if ([feedKey length]>0) 
	{
		[userInfoDictionary setValue:feedKey forKey:@"feedKey"];
	}
	
	if ([type length] > 0) 
	{
		[userInfoDictionary setValue:type forKey:@"feedType"];
	}
	
	
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	[request setDidFinishSelector:@selector(feedRequestFinished:)];
	[request setDidFailSelector:@selector(feedRequestFailed:)];
	[request setDidStartSelector:@selector(feedRequestStarted:)];
	
    
	[self startRequest:request];
}

NSString* encodeToPercentEscapeString(NSString *string) {
    return (NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
}

-(NSString *)getQueryURLForEntryFullSizedImage:(NSString *)entryFullSizedImageUrl {
    NSString * urlEncodingString = encodeToPercentEscapeString([entryFullSizedImageUrl gtm_stringByUnescapingFromHTML]);
    NSString * queryString = [NSString stringWithFormat:@"url=%@&size=960&ratio=fixed", urlEncodingString];
    return queryString;
}

-(void)fetchFullSizedImageForEntry:(Entry *) entry
{
	
    //NSString * queryString = [NSString stringWithFormat:@"url=%@&size=960&ratio=fixed", entry.fullSizedImageURL];
    
    //NSURL *url =[self fullURLforApi:@"feed_services/get_image" withQueryParameter:[self getQueryURLForEntryFullSizedImage:entry.fullSizedImageURL]];
    NSString *urlString = entry.fullSizedImageURL;
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:entry,FS_ENTRY_THUMBNAIL_KEY,nil]; 
    request.requestMethod = @"GET";
	[request setDidFinishSelector:@selector(fullSizedImageRequestFinished:)];
	[request setDidFailSelector:@selector(fullSizedImageRequestFailed:)];
	[request setDidStartSelector:@selector(fullSizedImageRequestStarted:)];
	
	[self startRequest:request];
}

-(NSString *)getQueryURLForEntryThumbnail:(NSString *)entryThumbnailUrl {
    NSString * urlEncodingString = encodeToPercentEscapeString([entryThumbnailUrl gtm_stringByUnescapingFromHTML]);
    NSString * queryString = [NSString stringWithFormat:@"url=%@&size=100&ratio=fixed", urlEncodingString];
    return queryString;
}

-(void)fetchThumbnailForEntry:(Entry*)entry
{
    //NSString * queryString = [NSString stringWithFormat:@"url=%@&size=100&ratio=fixed", entry.thumbnailURL];
    
    //NSURL *url =[self fullURLforApi:@"feed_services/get_image" withQueryParameter:[self getQueryURLForEntryThumbnail:entry.thumbnailURL]];
    NSURL *url = [NSURL URLWithString:entry.thumbnailURL];
	ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
    request.requestMethod = @"GET";
	
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:entry.objectID,FS_ENTRY_THUMBNAIL_KEY,nil]; 
	
	[request setDidFinishSelector:@selector(thumbnailImageRequestFinished:)];
	[request setDidFailSelector:@selector(thumbnailImageRequestFailed:)];
	[request setDidStartSelector:@selector(thumbnailImageRequestStarted:)];
		
	[self startRequest:request];
}

#pragma mark Feed Request - ASIHTTPRequestDelegate methods

-(void)fetchFinished:(NSString *)feedKey
{	
    //Get cached feed from default store and ensure that the object state is up-to-date
    Feed* newFeed = [self fetchFeedFromCacheWithKey:feedKey];
    [[newFeed managedObjectContext]refreshObject:newFeed mergeChanges:YES];
	[self.delegate feedService:self didFetchFeed:newFeed];
	[self.delegate feedServiceDidFinishFetchingFeed:self];
}

- (void)contextDidSave:(NSNotification*)notification
{
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    [localDataStore.managedObjectContext performSelectorOnMainThread:selector
                                                         withObject:notification
                                                      waitUntilDone:YES]; 
}

-(void)parseFeedData:(ASIHTTPRequest *)request
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        //CHECK FOR ERROR BEFORE PARSING, IF ERROR OR then call Fetch Failes.
    
    //PUT A LOCK HERE!!!!
    [[self cancelledLock] lock];
    NSData * responseData = [[request responseData] retain];
    self.canceled = NO;
    [[self cancelledLock] unlock];

    NSString * feedKey = nil;
    if(responseData !=nil && ([responseData length]> 0))
    {
    
        NSString * feedUrlString = nil;
        
        FeedParser * parser = nil;
                
        feedUrlString = (NSString *)[request.userInfo objectForKey:FS_REQUEST_URL_KEY];
        feedKey = (NSString *)[request.userInfo objectForKey:@"feedKey"];
        NSString * feedType = (NSString *)[request.userInfo objectForKey:@"feedType"];
        
        parser = [[FeedParser alloc]initWithData:(NSMutableData *)[request responseData]];
    
        parser.feedKey = feedKey;
        parser.feedURL = feedUrlString;
        
        DataStore * feedStore = [[DataStore alloc]init];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(contextDidSave:) 
                       name:NSManagedObjectContextDidSaveNotification 
                     object:feedStore.managedObjectContext];
        
        parser.objectStore = feedStore;
        
        [updateEntyLock lockForWriting];
        Feed * newFeed = [[parser startProcessingData] retain];
        [parser release];
        
        newFeed.moduleType  = feedType;
        
        if(!self.canceled)
            [feedStore save];
        
        [feedStore release];
        [updateEntyLock unlock];
        
        [newFeed release];
        
        [self performSelectorOnMainThread:@selector(fetchFinished:) withObject:[[feedKey copy] autorelease] waitUntilDone:NO];
    }
    [responseData release];
    [self destroyRequest:request];
    [pool release];
}


- (void)feedRequestStarted:(ASIHTTPRequest *)request
{
	NSURL * feedUrl = [request.userInfo objectForKey:FS_REQUEST_URL_KEY];
	
	[self.delegate feedService:self didStartFetchingFeedForUrl:feedUrl];
}


- (void)feedRequestFinished:(ASIHTTPRequest *)request
{
	
	[self performSelectorInBackground:@selector(parseFeedData:) withObject:request];
}

- (void)feedRequestFailed:(ASIHTTPRequest *)request
{
	
	[self.delegate feedService:self didFailFetchingFeedWithError:request.error];
	[self destroyRequest:request];
}

#pragma mark Full-SizedImage methods
-(void)fullSizedImageFinished:(Entry *)entry
{   
	
	NSNumber * number = [NSNumber numberWithInt:[self.delegate retainCount]];
	
	DebugLog(@"Retain count %@", number);
    [self.delegate feedService:self didFetchFullSizedImageForEntry:(Entry *)entry];
	[self.delegate feedServiceDidFinishFetchingFullSizedImage:self];
	
}

-(void)parseFullsizedImage:(ASIHTTPRequest *)request
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//PUT A LOCK HERE!!!!
	[[self cancelledLock] lock];
	NSData * responseData = [[request responseData] retain];
	[[self cancelledLock] unlock];

	if(responseData !=nil && ([responseData length]> 0))
	{
		Entry * entry = nil;
		UIImage* currentImage = nil;
		entry = [request.userInfo objectForKey:FS_ENTRY_THUMBNAIL_KEY];
		
		currentImage = [UIImage imageWithData:responseData];
        if (currentImage) 
        {
            NSString * imageFileName = [NSString stringWithFormat:@"%@_%@-fullSizedImage.jpg",[MD5 hash:entry.guid],[MD5 hash:entry.fullSizedImageURL]];
		
            [localDataStore lock];
            DataStore * feedStore = [[DataStore alloc]init];
            Entry * localEntry = (Entry *) [feedStore entityWithID:entry.objectID];
            // TODO:: change this wrong condition
            // entityWithID always return not nil object! but it could be fault object that could throw an exception
            if (localEntry) 
            {
                EntryImageReference * imageRef = (EntryImageReference *) [feedStore createObjectOfClass:[EntryImageReference class]];
                imageRef.fileName = imageFileName;
                imageRef.URLString = entry.fullSizedImageURL;
                if([imageRef saveImage:currentImage])
                {
                    localEntry.fullSizedImage = imageRef;
			
                }
                else
                {
                    [feedStore deleteEntity:imageRef];
                }
                [feedStore save];
			
                [[entry managedObjectContext]refreshObject:entry mergeChanges:YES];
                [localDataStore unlock];
                [self performSelectorOnMainThread:@selector(fullSizedImageFinished:) withObject:[entry retain] waitUntilDone:YES];
            }
            [feedStore release];
		}
	}
	[responseData release];
	[self destroyRequest:request];
	[pool release];
}

- (void)fullSizedImageRequestStarted:(ASIHTTPRequest *)request
{
	
}


- (void)fullSizedImageRequestFinished:(ASIHTTPRequest *)request
{
	[self performSelectorInBackground:@selector(parseFullsizedImage:) withObject:request];
}

- (void)fullSizedImageRequestFailed:(ASIHTTPRequest *)request
{
	[self.delegate feedService:self didFailFetchingFullSizedImageWithError:request.error];
	[self destroyRequest:request];
	
}


#pragma mark Thumbnail Image methods
-(void)thumbnailedFinished:(NSManagedObjectID*)entryId
{
    Entry * entry = (Entry *) [localDataStore entityWithID:entryId];
    [[entry managedObjectContext] refreshObject:entry mergeChanges:YES];
    
	[self.delegate feedService:self didFinishFetchingThumbnailForEntry:entry];
	
}

-(void)parseThumbnailData:(ASIHTTPRequest *)request
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //PUT A LOCK HERE!!!!
    [[self cancelledLock] lock];
    NSData * responseData = [[request responseData]retain];
    [[self cancelledLock] unlock];

    if(responseData !=nil && ([responseData length]> 0))
    {	
        UIImage* currentImage = [UIImage imageWithData:responseData];
        if (currentImage) 
        {
            DataStore * localStore = [[DataStore alloc]init];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center addObserver:self
                       selector:@selector(contextDidSave:) 
                           name:NSManagedObjectContextDidSaveNotification 
                         object:localStore.managedObjectContext];
            
            [updateEntyLock lock];

            NSManagedObjectID * entryId = [request.userInfo objectForKey:FS_ENTRY_THUMBNAIL_KEY];
            Entry * entry =  (Entry*)[localStore entityWithID:entryId];
            if(!entry)
            {
                [responseData release];
                [self performSelectorOnMainThread:@selector(thumbnailImageRequestFailed:) withObject:request waitUntilDone:NO];
                [updateEntyLock unlock];
                return;
            }
            
                
            NSString * imageFileName = [NSString stringWithFormat:@"%@_%@-thumbnailImage.jpg",[MD5 hash:entry.guid],[MD5 hash:entry.thumbnailURL]];

            EntryImageReference * imageRef = (EntryImageReference *)[localStore createObjectOfClass:[EntryImageReference class]];
            imageRef.fileName = imageFileName;
            imageRef.URLString = entry.thumbnailURL;
            if([imageRef saveImage:currentImage])
            {
                entry.thumbnailImage = imageRef;
            }
            else
            {
                [localStore deleteEntity:imageRef];
            }
            
            [localStore save];
            [updateEntyLock unlock];
            
            [self performSelectorOnMainThread:@selector(thumbnailedFinished:) withObject:[[entry.objectID copy]autorelease] waitUntilDone:NO];
            
            [localStore release];
        }
        else
        {
            [responseData release];
            [self performSelectorOnMainThread:@selector(thumbnailImageRequestFailed:) withObject:request waitUntilDone:NO];
            return;
        }
    }
    [responseData release];
    [self destroyRequest:request];
    [pool release];
}


- (void)thumbnailImageRequestStarted:(ASIHTTPRequest *)request
{
	
}


- (void)thumbnailImageRequestFinished:(ASIHTTPRequest *)request
{
	[self performSelectorInBackground:@selector(parseThumbnailData:) withObject:request];
}

- (void)thumbnailImageRequestFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"Thumnail Request Failed: %@ - %@", [request.error localizedDescription], request.url); 
	[self.delegate feedService:self didFinishFetchingThumbnailForEntry:nil];
	[self destroyRequest:request];
	
}

#pragma mark -
#pragma mark outstanding requests management
-(OAPointAboutASIFormDataRequest * )createNewOAuthRequestForURL:(NSURL *)requestURL
{
	[ASIHTTPRequest clearSession];	
	
	OAPointAboutASIFormDataRequest * request = nil;
	
	
	OAHMAC_SHA1SignatureProvider * signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc]init];
	
	request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:requestURL
														 consumer:self.consumer
															token:self.accessToken
															realm:nil
												signatureProvider:signatureProvider];
	
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	
	request.requestMethod = @"POST";
	request.useCookiePersistence = NO;
	
	[signatureProvider release];
	
	
	
	[[self cancelledLock] lock];
    request.delegate = self;
	[[self cancelledLock] unlock];
	
	return [request autorelease];
	
	
}

-(ASIFormDataRequest *)createNewRequestForURL:(NSURL *)requestURL
{
	ASIFormDataRequest * request = nil;
	[[self cancelledLock] lock];
		request = [self doCreateRequestForURL:requestURL];
		request.delegate = self;
	[[self cancelledLock] unlock];
	
		
	return request;

}

- (ASIFormDataRequest *)doCreateRequestForURL:(NSURL *)requestURL
{
	ASIFormDataRequest * request = [[ASIFormDataRequest alloc]initWithURL:requestURL];
	request.requestMethod = @"GET";
	
	[ASIHTTPRequest clearSession];
	request.useCookiePersistence = NO;
	[request setTimeOutSeconds:120];
	[request addRequestHeader:@"User-Agent" value:@"AppMakr Native i-Phone App Feed Reader 1.0"];
	return [request autorelease];
}

- (void)destroyRequest:(ASIHTTPRequest *)request
{
	[[self cancelledLock] lock];
		[self removeFromOutstandingRequests:request];
		[self doDestroyRequest:request];
	[[self cancelledLock] unlock];
	
}

- (void)doDestroyRequest:(ASIHTTPRequest *)request
{
	//[request release];
}


- (void)startRequest:(ASIHTTPRequest *)request
{
	[self addToOutstandingRequests:request];	
}

- (void)addToOutstandingRequests:(ASIHTTPRequest *)request
{
	[[self cancelledLock] lock];
		[self retain];
		[self.delegate retain]; 
	   [outstandingRequests addObject:request];
	   [sharedQueue addOperation:request];
	[[self cancelledLock] unlock];
	
}

- (void)removeFromOutstandingRequests:(ASIHTTPRequest *)request
{
	[[self cancelledLock] lock];
		[outstandingRequests removeObject:request];
		[self.delegate autorelease];
		[self autorelease];
	[[self cancelledLock] unlock];
	

}

@end
