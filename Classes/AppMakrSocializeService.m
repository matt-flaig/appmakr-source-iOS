//
//  AppMakrSocializeService.m
//  appbuildr
//
//  Created by William Johnson on 11/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrSocializeService.h"
#import "OAPointAboutASIFormDataRequest.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "NSDictionary_JSONExtensions.h"
#import "DataStore.h"
#import "CJSONDeserializer.h"
#import "NSDictionary_JSONExtensions.h"
#import "GeoPoint.h"
#import "EntryGeoPoint.h"
#import "DataStore.h" 
#import "EntryComment.h"
#import "EntryCommentGeoPoint.h"
#import "GlobalVariables.h"
#import "NSPredicate+Creation.h"
#import "Activity.h"
#import "FacebookWrapper.h"

#define serviceProviderName @"SOCIALIZE"
#define socializeUserKey @"socialize_current_user_id"

#define SMALL_IMAGE_URI     @"small_image_uri"
#define MEDIUM_IMAGE_URI    @"medium_image_uri"
#define LARGE_IMAGE_URI     @"large_image_uri" 

@interface AppMakrSocializeService()
- (void)authenticationRequestFinished:(ASIHTTPRequest *)request;
- (void)authenticationRequestFailed:(ASIHTTPRequest *)request;
- (BOOL) requestSuccessFull:(ASIHTTPRequest *)request error:(NSError **)error;
//- (NSURL *)fullURLforApi:(NSString *)api forEntryUrl:(NSString*)entryUrl;
- (AppMakrSocializeUser *) parseUserObject:(NSDictionary *) userDictionary;
- (void)fetchActivitiesForUser:(NSString *)userID near:(CLLocationCoordinate2D)location radius:(NSInteger)radius;

@end

@implementation AppMakrSocializeService

- (void) dealloc
{
	[super dealloc];
}

-(id<AppMakrSocializeServiceDelegate>)delegate
{
	return (id<AppMakrSocializeServiceDelegate>) [super delegate]; 	
}

-(void) setDelegate:(id<AppMakrSocializeServiceDelegate>)currentDelegate
{
	[super setDelegate:currentDelegate]; 	
}

-(BOOL) requestSuccessFull:(ASIHTTPRequest *)request error:(NSError **)error
{
    
	int statusCode = [request responseStatusCode];	
	if (statusCode != 200) 
	{
		
		NSString *statusMessage = [request responseStatusMessage];
		if (!statusMessage) 
		{
			statusMessage = @"Request Error"; //We should also include the URL here.  Must save the URL in the request because ASI says don't use the URL object of the request.
		}
		
		NSDictionary * errorDictionary = [NSDictionary dictionaryWithObject:statusMessage forKey:NSLocalizedDescriptionKey];
		*error = [[[NSError alloc]initWithDomain:@"Socialize" code:statusCode userInfo:errorDictionary]autorelease];
		
        DebugLog(@"Error ->%@", [*error localizedDescription]);

		return NO;
	}
	return YES;	
}
#pragma request creation and destroy


#pragma mark  =============================

-(NSArray *)fetchLikedEntries
{
	NSPredicate* predicate = [NSPredicate predicateWithFormat:@"liked == YES"]; 
	NSArray * likedEntries = [localDataStore retrieveEntitiesForClass:[Entry class] withSortDescriptors:nil andPredicate:predicate];
	
	return likedEntries;
}

-(BOOL)userIsAuthenticatedAnonymously
{
	NSAssert((self.consumer.key!=nil&& ([self.consumer.secret length]>0)), @"Invalid consumer key");
	NSAssert((self.consumer.secret!=nil&& ([self.consumer.secret length]>0)), @"Invalid consumer secret");
	
	return  (self.accessToken.key!=nil && self.accessToken.secret!=nil && ([self.accessToken.key length]>0) && ([self.accessToken.secret length]>0));
}


#define kThirdPartyDefaultsKey @"isUserThirdPartyAunthenticated"
-(BOOL)userIsAuthenticatedWithProfileInfo
{
    // need to add more checking here since the subsequesnt authenticate call might have failed.
    id key = [[NSUserDefaults standardUserDefaults] valueForKey:kThirdPartyDefaultsKey];
	
	if (key && (key != [NSNull null]) ){
        NSNumber* boolNumber =(NSNumber*) key;
        if ([boolNumber boolValue]){ 
            if ([FacebookWrapper facebook].accessToken != nil)
                return YES;
            else
                return NO;
        }
    }
    
    return NO;
}

-(void)authenticationComplete
{
    if (_isAuthenticatedWithThirdPartyInfo){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kThirdPartyDefaultsKey];
        _isAuthenticatedWithThirdPartyInfo = NO;
    }
	if ([self.delegate respondsToSelector:@selector(socializeService:didAuthenticateSuccessfully:error:)]) 
	{
		[self.delegate socializeService:self didAuthenticateSuccessfully:self.userIsAuthenticatedAnonymously error:nil];
	}
}

-(void)parseAuthenticationData:(ASIHTTPRequest *)request
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSData * responseData = [[request responseData]retain];
	NSString *responseBody = [[[NSString alloc] initWithData:responseData
													encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"authentication ressponse->%@", responseBody);
	
	
	NSError * error = nil;
	NSDictionary * responseDictionary = [NSDictionary dictionaryWithJSONData:responseData error:&error];
	[responseData release];
	
	
	NSString *laccessToken = nil;
	NSString *laccessTokenSecret = nil;
	
	
	NSDictionary * userDictionary = [responseDictionary objectForKey:@"user"]; 
	
	AppMakrSocializeUser * sUser = nil;
	if (userDictionary != nil) 
	{
        [localDataStore lock];
            sUser = [self parseUserObject:userDictionary];
            [[NSUserDefaults standardUserDefaults]setValue:sUser.userid forKey:socializeUserKey];
        [localDataStore save];
        [localDataStore unlock];
	}	
	
	laccessToken = [responseDictionary objectForKey:@"oauth_token"];  
	laccessTokenSecret = [responseDictionary objectForKey:@"oauth_token_secret"];
	self.accessToken = nil; 

	if (laccessToken && laccessTokenSecret) 
	{
		OAToken * newToken = [[OAToken alloc] initWithKey:laccessToken secret:laccessTokenSecret];
		
		self.accessToken = newToken;
		[newToken release];
	    [self.accessToken storeInUserDefaultsWithServiceProviderName:serviceProviderName prefix:serviceProviderName];
	}
	
	[self performSelectorOnMainThread:@selector(authenticationComplete) withObject:nil waitUntilDone:YES];
	[self destroyRequest:request];
	
	[pool release];
}

- (void)authenticationRequestFinished:(ASIHTTPRequest *)request
{
	
	NSError *error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
		[self performSelectorInBackground:@selector(parseAuthenticationData:) withObject:request];
	}
	else
	{
		request.error = error;
		[self authenticationRequestFailed:request];
	}
	
	
}

- (void)authenticationRequestFailed:(ASIHTTPRequest *)request
{
	
	if ([self.delegate respondsToSelector:@selector(socializeService:didAuthenticateSuccessfully:error:)]) 
	{
		
		NSError * error = request.error;
		
		DebugLog(@"Authentication failed: %@", [error localizedDescription]);
		[self.delegate socializeService:self didAuthenticateSuccessfully:NO error:error];
	}
	[self destroyRequest:request];
	
}

-(void)authenticate
{
	NSURL *url =[self fullURLforApi:@"socialize/authenticate"];
	
	OAPointAboutASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
		
	NSString * udid = @"";
	NSLog(@"udid = %@", udid);
	NSString * udidParameterString = [NSString stringWithFormat:@"udid=%@",udid];
	NSData *oauthPostData = [udidParameterString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [[NSUserDefaults standardUserDefaults] valueForKey:socializeUserKey];

	
	[request appendPostData:oauthPostData];
	
	[request setValidatesSecureCertificate:NO];
	[request setDidFinishSelector:@selector(authenticationRequestFinished:)];
	[request setDidFailSelector:@selector(authenticationRequestFailed:)];
	[request setTimeOutSeconds:3];
			
	[self startRequest:request];
}

-(void)authenticateWithThirdPartyCreds:(NSString*)userId accessToken:(NSString*)myaccessToken
{
    _isAuthenticatedWithThirdPartyInfo = YES;
	NSURL *url =[self fullURLforApi:@"socialize/authenticate"];
	
	OAPointAboutASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
    
	NSString * udid = @"";
	NSLog(@"udid = %@", udid);
    
    //NSString * socialize_id = (NSString *)[[NSUserDefaults standardUserDefaults]valueForKey:socializeUserKey];
    NSString * socialize_id = [[NSUserDefaults standardUserDefaults]valueForKey:socializeUserKey];
    if (socialize_id == nil) {
        socialize_id = @"";
    }

	NSString * udidParameterString = [NSString stringWithFormat:@"udid=%@&socialize_id=%@&auth_type=1&auth_token=%@&auth_id=%@",udid, socialize_id, myaccessToken, userId];
	NSData *oauthPostData = [udidParameterString dataUsingEncoding:NSUTF8StringEncoding];
	
	[request appendPostData:oauthPostData];
	
	[request setValidatesSecureCertificate:NO];
	[request setDidFinishSelector:@selector(authenticationRequestFinished:)];
	[request setDidFailSelector:@selector(authenticationRequestFailed:)];
	[request setTimeOutSeconds:3];
    
	[self startRequest:request];
}



-(void)statisticsFetchComplete:(NSArray *) entries
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchStatisticsForEntries:error:)]) 
	{
        [self.delegate socializeService:self didFetchStatisticsForEntries:entries error:nil];
    }
}

- (void)parseStatisticsDataForEntries:(ASIFormDataRequest *)request
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData * responseData = [[request responseData]retain];
	
	
	NSError * error = nil;
	NSDictionary * responseDictionary = [NSDictionary dictionaryWithJSONData:responseData error:&error];
	[responseData release];
	

	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
	
	NSArray * entries = (NSArray *)[request.userInfo objectForKey:@"entries"];
    
    DataStore * tempDataStore = [DataStore new];
    
	for(Entry * entry in entries)
	{  
		
		NSDictionary * dictionary = (NSDictionary *) [responseDictionary objectForKey:entry.url];
		
		if (dictionary != nil) 
		{
		
			NSNumber * views = (NSNumber *) [dictionary valueForKey:@"views"];
			NSNumber * likes = (NSNumber *) [dictionary valueForKey:@"likes"];
			NSNumber * comments = (NSNumber *) [dictionary valueForKey:@"comments"];
		
			//last comment date;
			id dateString = (NSString *) [dictionary objectForKey:@"last_comment_date"];
			NSDate * dateFromString = nil;
			if ([NSNull null]!=dateString) 
			{
				dateFromString = [dateFormatter dateFromString:(NSString *)dateString];
			}
			
		    if (views || likes || comments) 
		    {
                
                
                Entry * tempEntry = (Entry *)[tempDataStore entityWithID:entry.objectID];
                
                Statistics * stats = tempEntry.statistics;
                if (!stats) 
                {
                    
                    stats = (Statistics *) [tempDataStore createObjectOfClass:[Statistics class]];
                    tempEntry.statistics = stats;
                }
			   		
				
			   stats.numberOfViews = views;
                
               DebugLog(@"Like count from server %d of article %@", [likes intValue], tempEntry.title ); 
			   if([stats.isLastLikeCountRequestSuccess boolValue] == NO)
               {
                   int likesCount = [likes intValue];
                   [tempEntry.liked boolValue] == YES ? likesCount++ :likesCount--;
                   stats.numberOfLikes = [NSNumber numberWithInt:likesCount];
               }
               else
                   stats.numberOfLikes = likes; 
                
               if ([stats.numberOfComments intValue] < [comments intValue])
                   stats.hasNewComment = [NSNumber numberWithBool:YES];
                else
                   stats.hasNewComment = [NSNumber numberWithBool:NO];
                    
               DebugLog(@"Comments count from server %d of article %@", [comments intValue], tempEntry.title );  
			   stats.numberOfComments = comments;
			   stats.lastCommentDate = dateFromString;
                
               [tempDataStore save];
               
               [[entry managedObjectContext]refreshObject:entry mergeChanges:YES];
			  
		    }
		}
	}
	
    
    [tempDataStore release];	
	[self performSelectorOnMainThread:@selector(statisticsFetchComplete:) withObject:entries waitUntilDone:YES]; 
	
	[self destroyRequest:request];
	[pool release];
}

- (void)entryStatisticsRequestFailed:(ASIHTTPRequest *)request
{
	NSArray * entries = (NSArray *)[request.userInfo objectForKey:@"entries"];
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchStatisticsForEntries:error:)]) 
	{
        [self.delegate socializeService:self didFetchStatisticsForEntries:entries error:request.error];
    }
	[self destroyRequest:request];
}

- (void)entryStatisticsRequestFinished:(ASIHTTPRequest *)request
{
	NSError *error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
		[self performSelectorInBackground:@selector(parseStatisticsDataForEntries:) withObject:request];
	}
	else
	{
		request.error = error;
		[self entryStatisticsRequestFailed:request];
	}

}


-(void)fetchStatisticsForEntries:(NSArray * )entries
{
	
	if (entries) 
	{
	
	
		NSURL *url =[self fullURLforApi:@"socialize/get_stats_for_entries"];
		ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
		request.requestMethod = @"POST";
	
		for(Entry * entry in entries)
		{
		
			[request addPostValue:entry.url forKey:@"url"];
		}
	
		NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
		[userInfoDictionary setValue:entries forKey:@"entries"];
		request.userInfo = userInfoDictionary;
		[userInfoDictionary release];
	
		[request setDidFinishSelector:@selector(entryStatisticsRequestFinished:)];
		[request setDidFailSelector:@selector(entryStatisticsRequestFailed:)];
	
		request.delegate = self;
	
		[self startRequest:request];
	}
	
	
	
}

#pragma mark ===========================
-(void) updateLike: (Entry *) entry isLiked: (BOOL) isLikedKey
{
    DataStore * feedStore = [[DataStore alloc]init];
	Entry * oldEntry = (Entry *) [feedStore  retrieveSingleEntityForClass:[Entry class]
                                                                withValue:entry.guid
                                                             forAttribute:@"guid"];
	oldEntry.liked = [NSNumber numberWithBool:isLikedKey];
	DebugLog(@"OldEntry liked %d", [oldEntry.liked boolValue]);
    
	
	Statistics * stats = oldEntry.statistics;
	
	if(!stats)
	{
		stats = [Statistics new];
		oldEntry.statistics = stats;
		[stats release];
	}
	
	long int likes = [stats.numberOfLikes intValue];
    
    if(isLikedKey)
    {
        if (likes < 0)
            likes = 0;
        likes++;
    }
    else
    {
        if (likes > 0 )
            likes--;
        else 
            likes = 0;
    }
    
    
	
	stats.numberOfLikes = [NSNumber numberWithInt:likes];
	
	NSError * error = nil;
	[feedStore save:&error];
	[feedStore release];
	
	if (error) 
	{
		if ([self.delegate respondsToSelector:@selector(socializeService:didLikeEntry:error:)]) 
		{
			[self.delegate socializeService:self didLikeEntry:entry error:error];
		}
		return;
	}
	
	[[entry managedObjectContext]refreshObject:entry mergeChanges:YES]; 
    [[entry.statistics managedObjectContext]refreshObject:entry.statistics mergeChanges:YES]; 
	DebugLog(@"Entry liked %d", [entry.liked boolValue]);

}

-(void)updateLikeCountFlagForEntry: (Entry*) entry flag: (BOOL) value
{
    DataStore * feedStore = [[DataStore alloc]init];
	Entry * oldEntry = (Entry *) [feedStore  retrieveSingleEntityForClass:[Entry class]
                                                                withValue:entry.guid
                                                             forAttribute:@"guid"];
  
	
	Statistics * stats = oldEntry.statistics;
	
	if(!stats)
	{
		stats = [Statistics new];
		oldEntry.statistics = stats;
		[stats release];
	}

	stats.isLastLikeCountRequestSuccess = [NSNumber numberWithBool:value];
	
	NSError * error = nil;
	[feedStore save:&error];
	[feedStore release];
	
	if (error) 
	{
		if ([self.delegate respondsToSelector:@selector(socializeService:didLikeEntry:error:)]) 
		{
			[self.delegate socializeService:self didLikeEntry:entry error:error];
		}
		return;
	}
	
    [[entry.statistics managedObjectContext]refreshObject:entry.statistics mergeChanges:YES]; 
}

-(void)unlikeEntry:(Entry *)entry
{    
    [self updateLike: entry isLiked:NO];
	
    if([entry.statistics.isLastLikeCountRequestSuccess boolValue] == NO)
    {
        [self updateLikeCountFlagForEntry: entry flag: YES];
        return;
    }   
    
	NSURL *url =[self fullURLforApi:@"socialize/likes" forEntryUrl:entry.url];
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
	[userInfoDictionary setValue:entry forKey:@"url"];
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	request.requestMethod = @"DELETE";
	
	DebugLog(@"Delete->Like: url=%@",entry.url);
	
	[request setDidFinishSelector:@selector(likeRequestFinished:)];
	[request setDidFailSelector:@selector(likeRequestFailed:)];
	
	[self startRequest:request];
}

-(void)likeEntry:(Entry *)entry
{
    [self updateLike: entry isLiked:YES];

    if([entry.statistics.isLastLikeCountRequestSuccess boolValue] == NO)
    {
        [self updateLikeCountFlagForEntry: entry flag: YES];
        return;
    }  
    
	NSURL *url =[self fullURLforApi:@"socialize/likes"];
	
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
	[userInfoDictionary setValue:entry forKey:@"url"];
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	request.requestMethod = @"POST";
	[request setPostValue:entry.url forKey:@"url"];
	[request setPostValue:entry.title forKey:@"title"];
	[request setPostValue:entry.geoPoint.lat forKey:@"lat"];
	[request setPostValue:entry.geoPoint.lng forKey:@"lng"];
	
	DebugLog(@"Post->Like: url=%@, lat=%i,lng=%i",entry.url,entry.geoPoint.lat,entry.geoPoint.lng);
	
	[request setDidFinishSelector:@selector(likeRequestFinished:)];
	[request setDidFailSelector:@selector(likeRequestFailed:)];
	
	[self startRequest:request];
}

-(void)likeRequestFailed:(ASIHTTPRequest *)request
{
   	Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
    if(request.error.code != ASIRequestCancelledErrorType)
    {
        [self updateLikeCountFlagForEntry: entry flag: NO];
    }
    
	if ([self.delegate respondsToSelector:@selector(socializeService:didLikeEntry:error:)]) 
	{
		[self.delegate socializeService:self didLikeEntry:entry error:request.error];
	}
    
	[self destroyRequest:request];
}

-(void)likeRequestFinished:(ASIHTTPRequest *)request
{
	NSError * error = nil;
	
	if ([self requestSuccessFull:request error:&error])
	{
		
		Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
	    [self updateLikeCountFlagForEntry: entry flag: YES];
        
		if (self.delegate)
		{
			if ([self.delegate respondsToSelector:@selector(socializeService:didLikeEntry:error:)])
			{	//DebugLog(@"Old Entry <%@> liked %@", [oldEntry title], oldEntry.liked); 
				[[entry managedObjectContext]refreshObject:entry mergeChanges:YES]; 
				DebugLog(@"Entry <%@> liked %@", [entry title], entry.liked); 
				
				if ([self.delegate respondsToSelector:@selector(socializeService:didLikeEntry:error:)])
					 [self.delegate socializeService:self didLikeEntry:entry error:error];
				[self destroyRequest:request];
			}
		}
	}
	else
	{
		request.error = error;
		[self likeRequestFailed:request];
	}	
}



#pragma mark ASIHTTPRequest delegate callbacks
#pragma mark comment request methods
-(void)postComment:(ASIHTTPRequest *)request
{
	
	[self performSelectorInBackground:@selector(parseLikeResponse:) withObject:request];
}
-(void)postComment:(NSString *)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)sharLocationYesNO forEntry:(Entry *)entry commentType:(CommentMedium)commentType
{
    NSURL *url =[self fullURLforApi:@"socialize/comments"];
	
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
	[userInfoDictionary setValue:entry forKey:@"url"];
	[userInfoDictionary setValue:commentText forKey:@"commentText"];
    
    NSNumber * commentMedium =[NSNumber numberWithInt:commentType];
    [userInfoDictionary setValue:commentMedium forKey:@"medium"];
	
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	request.requestMethod = @"POST";
	
	[request setPostValue:entry.url forKey:@"url"];
	[request setPostValue:entry.title forKey:@"title"];
    
    if (commentLocation != nil) 
    {
        [request setPostValue:[NSNumber numberWithDouble:commentLocation.coordinate.latitude] forKey:@"lat"];
        [request setPostValue:[NSNumber numberWithDouble:commentLocation.coordinate.longitude] forKey:@"lng"];
   
        [request setPostValue:[NSNumber numberWithBool:sharLocationYesNO] forKey:@"share_location"];
        
        if (sharLocationYesNO)
        {
            [userInfoDictionary setValue:commentLocation forKey:@"location"];
        }
    }
   
	[request setPostValue:commentText forKey:@"comment"];
	[request setPostValue:commentMedium forKey:@"medium"];
	
	[request setDidFinishSelector:@selector(commentsPostFinished:)];
	[request setDidFailSelector:@selector(commentsPostFailed:)];
	
	[self startRequest:request];
    
}

-(void)postComment:(NSString *)commentText forEntry:(Entry *)entry commentType:(CommentMedium)commentType
{

    [self postComment:commentText location:nil shareLocation:NO forEntry:entry commentType:commentType];	
}


-(void)postComment:(NSString *)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)sharLocationYesNO forEntry:(Entry *)entry
{
     [self postComment:commentText location:commentLocation shareLocation:sharLocationYesNO forEntry:entry commentType:COMMENT_MEDIUM_DIRECT];

}

-(void)postComment:(NSString *)commentText forEntry:(Entry *)entry
{
	[self postComment:commentText forEntry:entry commentType:COMMENT_MEDIUM_DIRECT];
}
 

-(void)commentsPostFailed:(ASIHTTPRequest *)request
{
	
	if ([self.delegate respondsToSelector:@selector(socializeService:didPostCommentForEntry:error:)]) 
	{
		
		Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
		[self.delegate socializeService:self didPostCommentForEntry:entry error:request.error];
	}
	[self destroyRequest:request];
}

-(void)commentsPostFinished:(ASIHTTPRequest *)request
{
	NSError *error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
		Entry* entry = (Entry *)[request.userInfo objectForKey:@"url"];
		[self updateEntry:entry withNewViewDate:[NSDate date]];
		EntryComment * entComment = (EntryComment *) [localDataStore createObjectOfClass:[EntryComment class]];
		
		NSString * commentText = (NSString *)[request.userInfo objectForKey:@"commentText"];
		entComment.commentText = commentText;
		entComment.date = [NSDate date];
        
        CLLocation * commentLocation = (CLLocation *) [request.userInfo objectForKey:@"location"];
        if ( commentLocation != nil ) 
		{
			EntryCommentGeoPoint * entryCommentGeoPoint =  (EntryCommentGeoPoint *) [localDataStore createObjectOfClass:[EntryCommentGeoPoint class]];
            
			entryCommentGeoPoint.lat = [NSNumber numberWithDouble:commentLocation.coordinate.latitude];
			entryCommentGeoPoint.lng = [NSNumber numberWithDouble:commentLocation.coordinate.longitude];
		    
			entComment.geoPoint = entryCommentGeoPoint;
		}
		
		[entry addCommentsObject:entComment];
		
		NSString * userId = (NSString *)[[NSUserDefaults standardUserDefaults]valueForKey:socializeUserKey];
		AppMakrSocializeUser * sUser = (AppMakrSocializeUser *)[localDataStore  retrieveSingleEntityForClass:[AppMakrSocializeUser class]
																					 withValue:userId
																				  forAttribute:@"userid"];
		
		entComment.username = sUser.username;
		entComment.userImageURL = sUser.smallImageURL;
		
        
        DataStore * tempDataStore = [DataStore new];
        Entry * tempEntry = (Entry *)[tempDataStore entityWithID:entry.objectID];
        
        Statistics * stats = tempEntry.statistics;
        if (!stats) 
        {
            
            stats = (Statistics *) [tempDataStore createObjectOfClass:[Statistics class]];
            tempEntry.statistics = stats;
        }
        
		
		long int comments = [stats.numberOfComments intValue];
        
        NSNumber* commentType = (NSNumber *)[request.userInfo objectForKey:@"medium"];
        if ([commentType intValue] == COMMENT_MEDIUM_DIRECT) {
            comments++;
        }

		stats.numberOfComments = [NSNumber numberWithInt:comments];
        DebugLog(@" tempEntry.statistics.numberOfComments  %d", comments);
		
        [tempDataStore save];
        [tempDataStore release];
        [[entry managedObjectContext]refreshObject:entry mergeChanges:YES];
        [[entry managedObjectContext]refreshObject:entry.statistics mergeChanges:YES];
        
        DebugLog(@"After merging entry.statistics.numberOfComments  %d", [entry.statistics.numberOfComments intValue]);
		
        if ([self.delegate respondsToSelector:@selector(socializeService:didPostCommentForEntry:error:)]) 
		{			
			[self.delegate socializeService:self didPostCommentForEntry:entry error:request.error];
		}
		[self destroyRequest:request];
		
	}
	else
	{
		request.error = error;
		[self commentsPostFailed:request];
		
	}	
		
}

-(void)fetchCommentsForEntry:(Entry *)entry
{
	
	NSURL *url =[self fullURLforApi:@"socialize/comments" forEntryUrl:entry.url];
	
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
	[userInfoDictionary setValue:entry forKey:@"url"];
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	request.requestMethod = @"GET";
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
		
	[request setDidFinishSelector:@selector(commentRequestFinished:)];
	[request setDidFailSelector:@selector(commentRequestFailed:)];
	
	[self startRequest:request];	
	
}

-(void)commentRequestComplete:(Entry *)entry
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchCommentsForEntry:error:)]) 
	{
		
		[self.delegate socializeService:self didFetchCommentsForEntry:entry error:nil];
	}
}

- (void)parseCommentRequest:(ASIHTTPRequest *)request
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData * responseData = [[request responseData]retain];
	NSString *responseBody = [[[NSString alloc] initWithData:responseData
													encoding:NSUTF8StringEncoding] autorelease];
	DebugLog(@"%@", responseBody);
	
	NSError * error = nil;
	NSArray * JSONArray = [[CJSONDeserializer deserializer] deserialize:responseData error:&error];
	[responseData release];
	
	Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
	
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
	
	[localDataStore lock];


	[entry removeComments:entry.comments];		
	
	for(NSDictionary * commentsDictionary in JSONArray)
	{  

		
		
		EntryComment * entComment = (EntryComment *) [localDataStore createObjectOfClass:[EntryComment class]];
		
		id comment = (NSString *) [commentsDictionary objectForKey:@"comment"];
		
		if ([NSNull null]!=comment)
		{
			entComment.commentText = comment;
		}
		
		id dateString = (NSString *) [commentsDictionary objectForKey:@"date"];
		NSDate * dateFromString = nil;
		if ([NSNull null]!=dateString) 
		{
			dateFromString = [dateFormatter dateFromString:(NSString *)dateString];
		}
		
		entComment.date = dateFromString;
		
		
		
		id medium = (NSNumber *) [commentsDictionary objectForKey:@"medium"];
				
		if ([NSNull null]!=medium) 
		{
			entComment.medium = medium;
			
		}
		
		id appName = nil;
		id appID = nil;
		
		id appDictionary = (NSDictionary *) [commentsDictionary objectForKey:@"app"];
		
		if (appDictionary != nil && (appDictionary != [NSNull null]) ) 
		{
			appName = [appDictionary objectForKey:@"name"];
			appID = (NSNumber *)  [appDictionary objectForKey:@"id"];
			
		}
		
		
		if ([NSNull null]!=appName)
		{	
			entComment.appName = appName;
		}
		
		if ([NSNull null]!=appID)
		{
			entComment.appID = appID;
		}
		
		
		id username = nil;
		id userImageURL = nil;
        id userId = nil;
		id lat = nil;
		id lng =  nil;
		
		id userDictionary = (NSDictionary *) [commentsDictionary valueForKey:@"user"]; 
		
		if (userDictionary != nil && (userDictionary != [NSNull null]) ) 
		{
			
			username = (NSString *) [userDictionary objectForKey:@"username"];
			userImageURL = (NSString *) [userDictionary objectForKey:SMALL_IMAGE_URI];
			userId = (NSString *) [userDictionary objectForKey:@"id"];
		}
		
		if([NSNull null]!=username)
		{
			entComment.username = username;
		}
		
		if([NSNull null]!=userImageURL) 
		{
			entComment.userImageURL = userImageURL;
		}
        
        if([NSNull null]!=userId) 
		{
			entComment.userId = [userId stringValue];
		}
		 
        lat = (NSNumber * )[commentsDictionary valueForKey:@"lat"];
        lng =  (NSNumber * )[commentsDictionary valueForKey:@"lng"];
        
		if ((lat!=nil) && (lng!=nil) && ([NSNull null] != lat) && ([NSNull null]!=lng)) 
		{
			EntryCommentGeoPoint * entryCommentGeoPoint = (EntryCommentGeoPoint *) [localDataStore 
																					
																					
																					createObjectOfClass:[EntryCommentGeoPoint class]];
			entryCommentGeoPoint.lat = lat;
			entryCommentGeoPoint.lng = lng;
		    
			entComment.geoPoint = entryCommentGeoPoint;
		}
		
		[entry addCommentsObject:entComment];
	
	}
	
	
	[localDataStore unlock];
	
	[self performSelectorOnMainThread:@selector(commentRequestComplete:) withObject:entry waitUntilDone:YES]; 
	[self destroyRequest:request];
	[pool release];
}

-(void)commentRequestFinished:(ASIHTTPRequest *)request
{
	NSError * error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
	
		[self performSelectorInBackground:@selector(parseCommentRequest:) withObject:request];
	}
	else 
	{
		Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
		request.error = error;
		[self.delegate socializeService:self didFetchCommentsForEntry:entry error:request.error];;
	}

}
-(void)commentRequestFailed:(ASIHTTPRequest *)request
{
	
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchCommentsForEntry:error:)]) 
	{
		Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
		[self.delegate socializeService:self didFetchCommentsForEntry:entry error:request.error];
	}
	
	[self destroyRequest:request];
}

#pragma ================================

-(void)viewCommentsForEntry:(Entry *)entry
{
    
    DataStore * tempDataStore = [DataStore new];
    Entry * tempEntry = (Entry *)[tempDataStore entityWithID:entry.objectID];
    
    Statistics * stats = tempEntry.statistics;
    if (!stats) 
    {
        
        stats = (Statistics *) [tempDataStore createObjectOfClass:[Statistics class]];
        tempEntry.statistics = stats;
    }
    
    tempEntry.statistics.hasNewComment = [NSNumber numberWithBool:NO];
    
    [tempDataStore save];
    [tempDataStore release];
    [[entry managedObjectContext]refreshObject:entry mergeChanges:YES];
}


-(void)viewEntry:(Entry *)entry
{	
	
	
	DataStore * feedStore = [[DataStore alloc]init];
	Entry * oldEntry = (Entry *) [[feedStore  retrieveSingleEntityForClass:[Entry class]
																 withValue:entry.guid
															  forAttribute:@"guid"]retain];
	
	oldEntry.lastViewDate = [NSDate date];
	
	NSError * error = nil;
	[feedStore save:&error];
	[feedStore release];
	
	[oldEntry release];
	
	if(error)
	{
		if ([self.delegate respondsToSelector:@selector(socializeService:didViewEntry:error:)]) 
		{
			
			[self.delegate socializeService:self didViewEntry:entry error:error];
		}
		
		return;
	}
	
	[[entry managedObjectContext]refreshObject:entry mergeChanges:YES]; 
	
	
	NSURL *url =[self fullURLforApi:@"socialize/views"];
	
	ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	NSMutableDictionary * userInfoDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
	[userInfoDictionary setValue:entry forKey:@"url"];
	request.userInfo = userInfoDictionary;
	[userInfoDictionary release];
	
	request.requestMethod = @"POST";

	[request setPostValue:entry.url forKey:@"url"];
	[request setPostValue:entry.title forKey:@"title"];
	[request setPostValue:entry.geoPoint.lat forKey:@"lat"];
	[request setPostValue:entry.geoPoint.lng forKey:@"lng"];
	
	[request setDidFinishSelector:@selector(viewPostFinished:)];
	[request setDidFailSelector:@selector(viewPostFailed:)];
	
	[self startRequest:request];
	
}

-(void)updateEntry:(Entry*)entry withNewViewDate:(NSDate*)newDate{

	DataStore * feedStore = [[DataStore alloc]init];
	Entry * oldEntry = (Entry *) [feedStore  retrieveSingleEntityForClass:[Entry class]
																 withValue:entry.guid
															  forAttribute:@"guid"];
	
	oldEntry.lastViewDate = newDate;
	
	NSError * error = nil;
	[feedStore save:&error];
	[feedStore release];
	
}

-(void)viewPostFailed:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didViewEntry:error:)]) 
	{
		Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
		[self.delegate socializeService:self didViewEntry:entry error:request.error];
	}
	[self destroyRequest:request];
	
}

-(void)viewPostFinished:(ASIHTTPRequest *)request
{
	NSError * error = nil;
	
	if ([self requestSuccessFull:request error:&error])
	{
		
		if ([self.delegate respondsToSelector:@selector(socializeService:didViewEntry:error:)])
		{	 
			Entry * entry = (Entry *)[request.userInfo objectForKey:@"url"];
            
            DataStore * tempDataStore = [DataStore new];
            Entry * tempEntry = (Entry *)[tempDataStore entityWithID:entry.objectID];
            
            Statistics * stats = tempEntry.statistics;
            if (!stats) 
            {
                
                stats = (Statistics *) [tempDataStore createObjectOfClass:[Statistics class]];
                tempEntry.statistics = stats;
            }
             
			long int views = [stats.numberOfViews intValue];
		    views++;
			stats.numberOfViews = [NSNumber numberWithInt:views];
		
            [tempDataStore save];
            [tempDataStore release];
            [[entry managedObjectContext]refreshObject:entry mergeChanges:YES];
            
            
			[self.delegate socializeService:self didViewEntry:entry error:error];
			[self destroyRequest:request];
		}
	}
	else
	{
		request.error = error;
		[self viewPostFailed:request];
	}	
	
	

	
}


#pragma mark 

-(void)fetchActivities
{
	[self fetchActivitiesForUser:nil];
}

-(void)fetchActivitiesForCurrentUser
{
	[self fetchActivitiesForUser:@"current"];
}

-(void)fetchActivitiesForCurrentUserNear:(CLLocationCoordinate2D)location radius:(NSUInteger)radiusInMiles
{
	[self fetchActivitiesForUser:nil near:location radius:radiusInMiles ];
}

-(void)fetchActivitiesForUser:(NSString *)userID near:(CLLocationCoordinate2D)location radius:(NSInteger)radius
{
    NSString * queryString = nil;	
    
//    queryString = [NSString stringWithFormat:@"lat=%f&lng%f",  
//                   location.latitude, location.longitude];
    queryString = [NSString stringWithFormat:@"lat=%f&lng=%f",  
                   location.latitude, location.longitude];

    if (userID!=nil && [userID length]>0) 
    {
//        queryString = [NSString stringWithFormat:@"user=%@", userID];	
    }
    
   // NSURL *url =[self fullURLforApi:@"socialize/activity" withQueryParameter:queryString];
    NSURL *url =[self fullURLforApi:@"socialize/activity/nearby" withQueryParameter:queryString];
    
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
    
    request.requestMethod = @"GET";
    [request setDidFinishSelector:@selector(activityRequestFinished:)];
    [request setDidFailSelector:@selector(activityRequestFailed:)];
    
    request.delegate = self;
    
    [self startRequest:request];
}

-(void)fetchActivitiesForUser:(NSString *)userID
{
    NSString * queryString = nil;	

    if (userID!=nil && [userID length]>0) 
    {   
        queryString = [NSString stringWithFormat:@"user=%@", userID];	
    }

    NSURL *url =[self fullURLforApi:@"socialize/activity" withQueryParameter:queryString];

    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];

    request.requestMethod = @"GET";
    [request setDidFinishSelector:@selector(activityRequestFinished:)];
    [request setDidFailSelector:@selector(activityRequestFailed:)];
    request.delegate = self;
    
    [self startRequest:request];
}

-(void)activityRequestComplete:(NSArray *)activities
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchActivities:error:)]) 
	{
		[self.delegate socializeService:self didFetchActivities:activities error:nil];
	}
}

- (void)parseActivityRequest:(ASIHTTPRequest *)request
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData * responseData = [[request responseData]retain];
	NSString *responseBody = [[[NSString alloc] initWithData:responseData
													encoding:NSUTF8StringEncoding] autorelease];
	if(!responseBody) 
    {
		DebugLog(@"no response body");
	}
	NSError * error = nil;
	NSArray * JSONArray = [[CJSONDeserializer deserializer] deserialize:responseData error:&error];
	[responseData release];
	
	
	NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc]init]autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZ"];
	
	
	
	

	NSMutableArray * activities = [[NSMutableArray alloc]init];
	DebugLog(@"Act array retain count %i", [activities retainCount]);
	for(NSDictionary * activityDictionary in JSONArray)
	{  
		Activity * activity = [[Activity alloc]init];
		[activities addObject:activity];
		[activity release];
		
		id text = (NSString *) [activityDictionary objectForKey:@"text"];
		
		if ([NSNull null]!=text)
		{
			activity.text = text;
		}
		
		
		id title = (NSString *) [activityDictionary objectForKey:@"title"];
		
		if ([NSNull null]!= title)
		{
			activity.title = title;
		}

		id url = (NSString *) [activityDictionary objectForKey:@"url"];
		
		if ([NSNull null]!= url)
		{
			activity.url = url;
		}
		
		id dateString = (NSString *) [activityDictionary objectForKey:@"date"];
		NSDate * dateFromString = nil;
		if ([NSNull null]!=dateString) 
		{
			dateFromString = [dateFormatter dateFromString:(NSString *)dateString];
		}
		
		activity.date = dateFromString;
		
		
		
		id type = (NSNumber *) [activityDictionary objectForKey:@"type"];
		
		if ([NSNull null]!=type) 
		{
			activity.type = [type intValue];
		}
		
		id appName = nil;
		id appID = nil;
		
		id appDictionary = (NSDictionary *) [activityDictionary objectForKey:@"app"];
		
		if (appDictionary != nil && (appDictionary != [NSNull null]) ) 
		{
			appName = [appDictionary objectForKey:@"name"];
			appID = (NSNumber *)  [appDictionary objectForKey:@"id"];
			
		}
		
		
		if ([NSNull null]!=appName)
		{	
			activity.applicationName = appName;
		}
		
		if ([NSNull null]!=appID)
		{
			activity.applicationId = appID;
		}
		
		
		id username = nil;
		id userSmallImageURL = nil;
		id userLargeImageURL = nil;
		id userMediumImageURL = nil;
		id userId = nil;
		id lat = nil;
		id lng =  nil;
		
		id userDictionary = (NSDictionary *) [activityDictionary valueForKey:@"user"]; 
		
		if (userDictionary != nil && (userDictionary != [NSNull null]) ) 
		{
			
			username = (NSString *) [userDictionary objectForKey:@"username"];
		
			
			userId = (NSNumber *) [userDictionary objectForKey:@"id"];
			
			userSmallImageURL =  (NSString *) [userDictionary objectForKey:SMALL_IMAGE_URI];
			userMediumImageURL = (NSString *) [userDictionary objectForKey:MEDIUM_IMAGE_URI];
			userLargeImageURL =  (NSString *) [userDictionary objectForKey:LARGE_IMAGE_URI];
			lat = (NSNumber * )[activityDictionary valueForKey:@"lat"];
			lng =  (NSNumber * )[activityDictionary valueForKey:@"lng"];
		}
		
		if([NSNull null] != userId)
		{
			activity.userId = [userId stringValue];
		}
		
		if([NSNull null] != username)
		{
			activity.username = username;
		}
		
		if([NSNull null]!= userSmallImageURL) 
		{
			activity.userSmallImageURL = userSmallImageURL;
		}

		if([NSNull null]!= userMediumImageURL) 
		{
			activity.userMediumImageURL = userMediumImageURL;
		}

		if(([NSNull null]!= lat && [NSNull null]!= lng)) 
		{
            activity.myGeoPoint = [[MyGeoPoint alloc ] init];
            activity.myGeoPoint.lat = lat;
            activity.myGeoPoint.lng = lng;
		}

		id entryURL = nil;
		entryURL = (NSString *) [activityDictionary valueForKey:@"url"]; 
		
		if ([NSNull null]!=entryURL && entryURL !=nil) 
		{
			DataStore * feedStore = localDataStore;
			NSPredicate* predicate = [NSPredicate predicateWithValue:entryURL forAttribute:@"url"]; 
			
			
			NSArray* entryArray = (NSArray *) [feedStore  retrieveEntitiesForClass:[Entry class] 
														withSortDescriptors:nil
															   andPredicate:predicate];
											
			if ([entryArray count] > 0) 
			{
				activity.entry = (Entry *) [entryArray objectAtIndex:0];
			}
		}
	}
	
	[self performSelectorOnMainThread:@selector(activityRequestComplete:) withObject:activities waitUntilDone:YES]; 
	DebugLog(@"Act array retain count %i", [activities retainCount]);
	[activities release];
	[self destroyRequest:request];
	[pool release];
	
}

-(void)activityRequestFailed:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchActivities:error:)]) 
	{
		[self.delegate socializeService:self didFetchActivities:nil error:request.error];
	}
	[self destroyRequest:request];
}

-(void)activityRequestFinished:(ASIHTTPRequest *)request
{
	NSError * error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
		
		[self performSelectorInBackground:@selector(parseActivityRequest:) withObject:request];
	}
	else 
	{
		request.error = error;
		[self activityRequestFailed:request];
	}
	
}

#pragma mark Profile methods
-(void) profileRequestComplete:(AppMakrSocializeUser *)user
{
	
	[self.delegate socializeService:self didFetchProfile:user error:nil];
	
}

-(AppMakrSocializeUser *) parseUserObject:(NSDictionary *) userDictionary
{
	AppMakrSocializeUser * sUser = nil;
	
	if (userDictionary != nil) 
	{
		id userID = (NSString *) [userDictionary objectForKey:@"id"];
	
        if([NSNull null]!= userID) 
		{
			
			sUser = (AppMakrSocializeUser *)[[localDataStore  retrieveSingleEntityForClass:[AppMakrSocializeUser class]
																	  withValue:[userID stringValue]
																   forAttribute:@"userid"]retain];
			if (sUser == nil)
			{
				sUser = (AppMakrSocializeUser *) [localDataStore createObjectOfClass:[AppMakrSocializeUser class]];
				sUser.userid = [userID stringValue];
			}
		}

		
		id username = (NSString *) [userDictionary objectForKey:@"username"];
		id userSmallImageURL = (NSString *) [userDictionary objectForKey:SMALL_IMAGE_URI];
		id userMediumImageURL = (NSString *) [userDictionary objectForKey:MEDIUM_IMAGE_URI];
		id userLargeImageURL = (NSString *) [userDictionary objectForKey:LARGE_IMAGE_URI];
		id userFirstName = (NSString *) [userDictionary objectForKey:@"first_name"];
		id userLastName = (NSString *) [userDictionary objectForKey:@"last_name"];
		id userDescription = (NSString *) [userDictionary objectForKey:@"description"];
		
		
        if([NSNull null] != username)
		{
			sUser.username = username;
		}
		
		if([NSNull null]!= userSmallImageURL) 
		{
			sUser.smallImageURL = userSmallImageURL;
			
		}
		if([NSNull null]!= userMediumImageURL) 
		{
			sUser.mediumImageURL = userMediumImageURL;
			
		}
		if([NSNull null]!= userLargeImageURL) 
		{
			sUser.largeImageURL = userLargeImageURL;
		}
		
		if([NSNull null]!=userFirstName) 
		{
			sUser.firstName = userFirstName;
		}
		
		if([NSNull null]!= userLastName) 
		{
			sUser.lastName = userLastName;
		}
		if([NSNull null]!= userDescription) 
		{
			sUser.userDescription = userDescription;
		}
        
	}	
	
	return sUser;	
}

-(void)parseProfileRequest:(ASIHTTPRequest *)request
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData * responseData = [[request responseData]retain];
	NSString *responseBody = [[[NSString alloc] initWithData:responseData
								
													encoding:NSUTF8StringEncoding] autorelease];
	if(!responseBody) 
    {
		DebugLog(@"response body is nil");
	}
	NSError * error = nil;
	NSDictionary * userDictionary = (NSDictionary *)[[CJSONDeserializer deserializer] deserialize:responseData error:&error];
	[responseData release];
	AppMakrSocializeUser * sUser = nil;
	
    if (userDictionary != nil) 
    {
        sUser = [self parseUserObject:userDictionary];
    }
		
	[self performSelectorOnMainThread:@selector(profileRequestComplete:) withObject:sUser waitUntilDone:YES]; 
	[sUser release];
	[self destroyRequest:request];
	[pool release];
	
}

-(void)profileRequestFailed:(ASIHTTPRequest *)request
{
	if ([self.delegate respondsToSelector:@selector(socializeService:didFetchActivities:error:)]) 
	{
		[self.delegate socializeService:self didFetchProfile:nil error:request.error];
	}
	[self destroyRequest:request];
}

-(void)profileRequestFinished:(ASIHTTPRequest *)request
{
	NSError * error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
		
		[self performSelectorInBackground:@selector(parseProfileRequest:) withObject:request];
	}
	else 
	{
		request.error = error;
		[self profileRequestFailed:request];
	}
	
}




-(void)fetchProfileForUser:(NSString *)userID
{
	
	NSString * queryString = nil;	
	
	
	if (userID!=nil && [userID length]>0) 
	{
		queryString = [NSString stringWithFormat:@"user=%@", userID];	
	}
	
	
	NSURL *url =[self fullURLforApi:@"socialize/profile" withQueryParameter:queryString];
	
	ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	request.requestMethod = @"GET";
	
	
	
	[request setDidFinishSelector:@selector(profileRequestFinished:)];
	[request setDidFailSelector:@selector(profileRequestFailed:)];
	
	request.delegate = self;
	
	[self startRequest:request];
}

-(void)postToProfileFirstName:(NSString *) firstName lastName:(NSString *)lastName 
				  description:(NSString *)description image:(UIImage *)profileImage
{
	NSURL *url =[self fullURLforApi:@"socialize/profile"];
	
    ASIFormDataRequest * request = [self createNewOAuthRequestForURL:url];
	
	request.requestMethod = @"POST";
	
	[request setPostValue:firstName forKey:@"first_name"];
	[request setPostValue:lastName  forKey:@"last_name"];
	[request setPostValue:description forKey:@"description"];	
	
	if (profileImage) 
	{
		NSData * imageData = UIImageJPEGRepresentation(profileImage, 1);
		[request setData:imageData withFileName:@"profileImage.jpg" andContentType:@"image/jpeg" forKey:@"picture"];
		
	}
	
	
	[request setDidFinishSelector:@selector(profilePostFinished:)];
	[request setDidFailSelector:@selector(profilePostFailed:)];
	
	[self startRequest:request];	
	
}



-(void) profilePostComplete:(AppMakrSocializeUser *)user
{
    if ([self.delegate respondsToSelector:@selector(socializeService:didPostToProfileWithError:)]) 
    {
        [self.delegate socializeService:self didPostToProfileWithError:nil];
    }
	
}

-(void)parseProfilePostResponse:(ASIHTTPRequest *)request
{
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	
	NSData * responseData = [[request responseData]retain];
	NSString *responseBody = [[[NSString alloc] initWithData:responseData
                               
													encoding:NSUTF8StringEncoding] autorelease];
	if(!responseBody) 
    {
		DebugLog(@"response body is nil");
	}
    else
    {
        NSError * error = nil;
        NSDictionary * userDictionary = (NSDictionary *)[[CJSONDeserializer deserializer] deserialize:responseData error:&error];
        [responseData release];
        AppMakrSocializeUser * sUser = nil;
	
        if (userDictionary != nil) 
        {
            [localDataStore lock];
                sUser = [self parseUserObject:userDictionary];
            [localDataStore save];
            [localDataStore unlock];
        }
    
        [self performSelectorOnMainThread:@selector(profilePostComplete:) withObject:sUser waitUntilDone:YES];
        [sUser release];
    }
	 
	[self destroyRequest:request];
	[pool release];
	
}

-(void)profilePostFailed:(ASIHTTPRequest *)request
{
	
	if ([self.delegate respondsToSelector:@selector(socializeService:didPostToProfileWithError:)])
	{
		[self.delegate socializeService:self didPostToProfileWithError:request.error];
        
	}
	[self destroyRequest:request];
}



-(void)profilePostFinished:(ASIHTTPRequest *)request
{
	NSError *error = nil;
	if ([self requestSuccessFull:request error:&error])
	{
            
        [self performSelectorInBackground:@selector(parseProfilePostResponse:) withObject:request];

	}
	else
	{
		request.error = error;
		[self profilePostFailed:request];
		
	}	
	
}


#pragma ======================
#pragma mark Social Service Authentication  callbacks

@end
