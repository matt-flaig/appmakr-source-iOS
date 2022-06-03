//
//  SocializeServiceTests.m
//  appbuildr
//
//  Created by William Johnson on 12/6/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeServiceTests.h"
#import "AppMakrSocializeService.h"
#import "FeedParser.h"
#import "Feed.h"
#import "Entry.h"
#import "GlobalVariables.h"
#import "FeedService.h"
#import "AbstractParser.h"

static BOOL authenticationRequestComplete = NO;

@implementation SocializeServiceTests

@synthesize socializeService;
@synthesize theFeed;

- (void) setUp

{

	NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
	NSString *modelPath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.mom"];
	NSString * databasePath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.sqlite"];
	
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	if (modelPath!= nil) 
	{
	   [defaults setObject:modelPath forKey:@"CDModelPath"];  //this probably isn't the best way because the application path can change.
		
	}
	
	if (databasePath!=nil) 
	{
		[defaults setObject:databasePath forKey:@"CDDatabseFilePath"]; //this probably isn't the best way because the application path can change.
		
	}
	
	
	
    AppMakrSocializeService * service = [[AppMakrSocializeService alloc]init];
	service.delegate = self;  
	self.socializeService = service;
	[service release];
	
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path1 = [bundle pathForResource:@"Yahoo_Pipes_MergeFeedTest_1" ofType:@"txt"];
	
	NSURL *url1 = [NSURL fileURLWithPath:path1];
	
	NSMutableData *itemsData1 = [[NSMutableData alloc] initWithContentsOfURL:url1];
	
	FeedParser * parser1 = [[FeedParser alloc] initWithData:itemsData1];  //This feed should have 8 entries.
	theFeed= [parser1 startProcessingData];
	theFeed.url = path1;
	[parser1 release];
	
	
	
}



//- (void) tearDown
//
//{
//	
//	[self.socializeService cancelAllFetchRequests];
//	self.socializeService = nil;
//	
//}

-(void)privateTestAuthentication
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"Test is running Authentication.");
	[self.socializeService authenticate];
	
	[pool release];
}

//-(void)testSocialize
//{
//	[self performSelectorInBackground:@selector(privateTestAuthentication) withObject:nil];
//	while (!authenticationRequestComplete)
//    {
//		
//		[NSThread sleepForTimeInterval:10];
//		//NSLog(@"Im Asleep");
//	}
////	
////	STFail(@"testing socialize");
//}

//-(void)testMe
//{
//	STFail(@"me failed.");	
//}
	


-(void)privateTestfetchStatistics
{
	[self.socializeService fetchStatisticsForEntries:[theFeed.entries allObjects]];
}

-(void)privateTestfetchComments
{
	[self.socializeService fetchCommentsForEntry:[theFeed.entries anyObject]];
}

-(void)privateTestlikeEntry
{
	Entry * entry  = (Entry *) [self.theFeed.entries anyObject];
    [self.socializeService likeEntry:entry];	
}

-(void)privateTestViewEntry
{
	Entry * entry  = (Entry *) [self.theFeed.entries anyObject];
    [self.socializeService viewEntry:entry];	
}

-(void)privateTestviewCommentsForEntry
{
    Entry * entry  = (Entry *) [self.theFeed.entries anyObject];
    entry.statistics.hasNewComment = [NSNumber numberWithBool:YES]; 
    [self.socializeService viewCommentsForEntry:entry];	
    
    
    STAssertFalse([entry.statistics.hasNewComment boolValue], @"", @"New comment should be false");
    
}
-(void)privateTestPostComment
{
	Entry * entry  = (Entry *) [self.theFeed.entries anyObject];
    [self.socializeService postComment:@"Unit Test comment" forEntry:entry];	
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didAuthenticateSuccessfully:(BOOL)successYesOrNO error:(NSError *)error
{
	NSLog(@"Authentication passes the test !!!!!");
	authenticationRequestComplete = YES;
    NSString * errorMessage = [NSString stringWithFormat:@"%@",[error localizedDescription]];
	STAssertTrue(successYesOrNO, errorMessage);
	STAssertTrue(self.socializeService.userIsAuthenticatedAnonymously, @"Authentication request returned but userIsAutheticated is false.");
	
    //[self privateTestfetchStatistics];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didStartFetchingStatisticsForEntry:(Entry *)entry
{
	
	
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchStatisticsForEntries:(NSArray	*)entries error:(NSError *)error
{
	if (error) 
	{
		NSString * errorMessage = [NSString stringWithFormat:@"%@",[error localizedDescription]];
		NSLog(@"Statistics fetch failed:%@", errorMessage);
	}
	
	for (Entry * e in entries) 
	{
		STAssertNotNil(e.statistics, @"statics for entry is nil.");
	}
								   
	[self privateTestPostComment];
}
-(void) socializeService:(AppMakrSocializeService *)socializeService didFailFetchingStatisticsForEntry:(Entry *)entry withError:(NSError *)error
{
	STFail(@"Fetch failed");	
}
-(void) socializeServiceDidFinishFetchingStatisticsForEntry:(Entry *)entry
{
	
}
-(void) socializeService:(AppMakrSocializeService *)socializeService didLikeEntry:(Entry *)entry error:(NSError *)error
{
	STAssertTrue([entry.liked boolValue],@"Entry like failed");
	[self privateTestViewEntry];
	
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didViewEntry:(Entry *)entry error:(NSError *)error
{
	if (error!= nil) 
	{
		STFail(@"view post failed for entry");
	}
	
	STAssertNotNil(entry.lastViewDate, @"Last view date is nil");
	//STAssertEqual([entry.views intValue], , @"Entry was not viewed.");
	
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didPostCommentForEntry:(Entry *)entry error:(NSError *)error
{
	if (error != nil) 
	{
		STFail(@"comment post failed for entry");
	}
	
	[self privateTestfetchComments];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchCommentsForEntry:(Entry *)entry error:(NSError *)error
{
	if (error != nil) 
	{
		STFail(@"comment fetch failed for entry");
	}
	
	STAssertEquals([entry.comments count], 1, @"Comment Fetch failed.");
	[self privateTestlikeEntry];
}

@end
