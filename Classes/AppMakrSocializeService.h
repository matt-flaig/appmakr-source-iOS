//
//  AppMakrSocializeService.h
//  appbuildr
//
//  Created by William Johnson on 11/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "ASIHTTPRequest.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "ASIHTTPRequestDelegate.h"
#import "FeedService.h"
#import "Entry+Extensions.h"
#import "EntryComment+Extensions.h"
#import "Statistics.h"
#import "AppMakrSocializeUser.h"



extern NSString * const kSocializeConsumerKeyKey;
extern NSString * const kSocializeConsumerSecretKey;

@class AppMakrSocializeService;
@protocol AppMakrSocializeServiceDelegate<FeedServiceDelegate>

@optional
-(void) socializeService:(AppMakrSocializeService *)socializeService didAuthenticateSuccessfully:(BOOL)successYesOrNO error:(NSError *)error;

-(void) socializeService:(AppMakrSocializeService *)socializeService didStartFetchingStatisticsForEntry:(Entry *)entry;
-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchStatisticsForEntries:(NSArray	*)entries error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didFailFetchingStatisticsForEntry:(Entry *)entry withError:(NSError *)error;
-(void) socializeServiceDidFinishFetchingStatisticsForEntry:(Entry *)entry;
-(void) socializeService:(AppMakrSocializeService *)socializeService didLikeEntry:(Entry *)entry error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didViewEntry:(Entry *)entry error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didPostCommentForEntry:(Entry *)entry error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchCommentsForEntry:(Entry *)entry error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchActivities:(NSArray *)activities error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchProfile:(AppMakrSocializeUser *)user error:(NSError *)error;
-(void) socializeService:(AppMakrSocializeService *)socializeService didPostToProfileWithError:(NSError *)error;


@end

@class Comment;
@interface AppMakrSocializeService : FeedService 
{
    
    @private 
    BOOL _isAuthenticatedWithThirdPartyInfo;
}
@property (nonatomic, assign) id<AppMakrSocializeServiceDelegate> delegate;
@property (readonly) BOOL userIsAuthenticatedAnonymously;// this flag is set to YES when the user is authenticated anonymously and may or may not have have authenticated via a third party
@property (readonly) BOOL userIsAuthenticatedWithProfileInfo;// this flag is set to YES  via a third party

-(void)authenticate;
-(void)authenticateWithThirdPartyCreds:(NSString*)userId accessToken:(NSString*)accessToken;
-(void)fetchStatisticsForEntries:(NSArray * )entries;
-(void)fetchCommentsForEntry:(Entry *)entry;
-(void)fetchActivities;
-(void)fetchActivitiesForCurrentUser;
-(void)fetchActivitiesForCurrentUserNear:(CLLocationCoordinate2D)location radius:(NSUInteger)radiusInMiles;
-(void)fetchActivitiesForUser:(NSString *)userId;
-(void)fetchProfileForUser:(NSString *)userID;



-(NSArray *)fetchLikedEntries;
-(void)likeEntry:(Entry *)entry;
-(void)unlikeEntry:(Entry *)entry;
-(void)viewCommentsForEntry:(Entry *)entry;   //This is synchronus for now, because this is local and doesn't contact the server (web).
-(void)viewEntry:(Entry *)entry;
-(void)updateEntry:(Entry*)entry withNewViewDate:(NSDate*)newDate;
-(void)postComment:(NSString *)commentText forEntry:(Entry *)entry;

-(void)postComment:(NSString *)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)sharLocationYesNO forEntry:(Entry *)entry;

-(void)postComment:(NSString *)commentText forEntry:(Entry *)entry commentType:(CommentMedium)commentType;

-(void)postComment:(NSString *)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)sharLocationYesNO forEntry:(Entry *)entry commentType:(CommentMedium)commentType;

-(void)postToProfileFirstName:(NSString *) firstName lastName:(NSString *)lastName 
				description:(NSString *)description image:(UIImage *)profileImage;
@end

