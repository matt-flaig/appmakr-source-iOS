//
//  LogicTests.m
//  appbuildr
//
//  Created by Brian Schwartz on 1/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

/* Common Macros
 STAssertNotNil(a1, description, ...)
 STAssertTrue(expression, description, ...)
 STAssertFalse(expression, description, ...)
 STAssertEqualObjects(a1, a2, description, ...)
 STAssertEquals(a1, a2, description, ...)
 STAssertThrows(expression, description, ...)
 STAssertNoThrow(expression, description, ...)
 STFail(description, ...)
*/

#import "LogicTests.h"
#import "FeedParser.h"
#import "Feed.h"
#import "Entry.h"
#import "GlobalVariables.h"
//#import "UnitTestFeedService.h"
#import "FeedService.h"
#import "AbstractParser.h"
#import "DataStore.h"
#import "Feed+Extensions.h"

@implementation LogicTests

-(void) setUp
{
	NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
	NSString *modelPath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.mom"];
	NSString * databasePath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.sqlite"];
	
	//NSLog(@"I'm HERE!!!! -> %@", modelPath);
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	if (modelPath!= nil) 
	{
		[defaults setObject:modelPath forKey:@"CDModelPath"];  //this probably isn't the best way because the application path can change.
		NSLog(@"Model Path -> %@", modelPath);
		
	}
	
	if (databasePath!=nil) 
	{
		[defaults setObject:databasePath forKey:@"CDDatabseFilePath"]; //this probably isn't the best way because the application path can change.
		
	}
	
	[DataStore initialize];
	
	
}

- (void) tearDown

{
	
    // Release data structures here.
	[DataStore shutdown];
	
}

#pragma mark Atom Tests
// Atom Tests

-(void)testEventful {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Eventful" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);
	
	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFacebookPages {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Facebook_Pages" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 31, [NSString stringWithFormat:@"Found %d of 31 entries in this feed: %@",[[parsedFeed entries] count],path]);
	
	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 28, [NSString stringWithFormat:@"Found %d of 28 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFlickr {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Flickr" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 20, [NSString stringWithFormat:@"Found %d of 20 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFriendFeed {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"FriendFeed" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 30, [NSString stringWithFormat:@"Found %d of 30 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	NSLog(@"thunmbail count %i", thumbnailCount);
	STAssertTrue(thumbnailCount == 30, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testGoogleCalendar {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Google_Calendar" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testGoogleReader {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Google_Reader" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testGowalla {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Gowalla" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 20, [NSString stringWithFormat:@"Found %d of 20 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testNing {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Ning" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 29, [NSString stringWithFormat:@"Found %d of 29 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 15, [NSString stringWithFormat:@"Found %d of 15 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTwitterSearch {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Twitter_Search" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 15, [NSString stringWithFormat:@"Found %d of 15 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTypePad {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"TypePad" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 50, [NSString stringWithFormat:@"Found %d of 50 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 50, [NSString stringWithFormat:@"Found %d of 50 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testWeblogs {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Weblogs" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 12, [NSString stringWithFormat:@"Found %d of 12 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

#pragma mark RDF Tests
// RDF Tests

-(void)testBlog {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Blog" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
    parser.feedKey = @"Blog";
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);
	
	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 2, [NSString stringWithFormat:@"Found %d of 2 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testSlashdot {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Slashdot" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
    parser.feedKey = @"Slashdot";
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 15, [NSString stringWithFormat:@"Found %d of 15 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}


-(void)test_750_RSS_Cheltenham
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Test_750_RSS_Cheltenham" ofType:@"txt"];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
    parser.feedKey = @"Test_750_RSS_Cheltenham";
	Feed *parsedFeed = [parser startProcessingData];
	int entryCount = 1;
	
	NSArray * entryArray = [parsedFeed entriesInOriginalOrder];
    
	STAssertTrue([entryArray count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[entryArray count],path]);
	
	for(Entry *entry in entryArray)
	{
		
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
	    entryCount++;
	}
	
	
	Entry * firstEntry = (Entry *) [entryArray objectAtIndex:0];
	
	STAssertTrue(([firstEntry.order intValue] == 0), [NSString stringWithFormat:@"Entry #1 (the first entry) has the wrong sequence number (%d)",[firstEntry.order intValue]]);
	STAssertTrue([firstEntry.title isEqualToString:@"Making the right choice for Cheltenham"], [NSString stringWithFormat:@"Entry #1 (the first entry) has the wrong title (%d)",firstEntry.title]);
    
	Entry * middleEntry = (Entry *) [entryArray objectAtIndex:10];  //Use the 11th( newsID= 707) entry as the middle entry 
	
	STAssertTrue(([middleEntry.order intValue] == 10), [NSString stringWithFormat:@"Entry #11 (the middleEntry) has the wrong sequence number (%d)",[middleEntry.order intValue]]);
	STAssertTrue([middleEntry.title isEqualToString:@"Council receives petition"], [NSString stringWithFormat:@"Entry #11 (the middleEntry) has the wrong title (%d)",middleEntry.title]);
    
	
	Entry * lastEntry = (Entry *) [entryArray objectAtIndex:19];  
	
	STAssertTrue(([lastEntry.order intValue] == 19), [NSString stringWithFormat:@"Entry #19 (the last entry) has the wrong sequence number (%d)",[lastEntry.order intValue]]);
	STAssertTrue([lastEntry.title isEqualToString:@"Free fitness at leisure@cheltenham this weekend"], [NSString stringWithFormat:@"Entry #19 (the last entry) has the wrong title (%d)",lastEntry.title]);
}

#pragma mark RSS Tests
// RSS Tests

-(void)testBing {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Bing" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
    parser.feedKey = @"Bing";
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testBlogspot {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Blogspot" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 25, [NSString stringWithFormat:@"Found %d of 25 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testDailymotion {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Dailymotion" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 16, [NSString stringWithFormat:@"Found %d of 16 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 16, [NSString stringWithFormat:@"Found %d of 16 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testDelicious {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Delicious" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testDigg {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Digg" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 40, [NSString stringWithFormat:@"Found %d of 40 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 40, [NSString stringWithFormat:@"Found %d of 40 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testEBay {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"eBay" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 100, [NSString stringWithFormat:@"Found %d of 100 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 100, [NSString stringWithFormat:@"Found %d of 100 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testEventbrite {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Eventbrite" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 2, [NSString stringWithFormat:@"Found %d of 2 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 1, [NSString stringWithFormat:@"Found %d of 1 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFeedBurner {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"FeedBurner" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFeedProxy {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"FeedProxy" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 25, [NSString stringWithFormat:@"Found %d of 25 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testFoursquare {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Foursquare" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
    parser.feedKey =@"Foursquare"; 
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testGoogleGroups {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Google_Groups" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testGoogleNews {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Google_News" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testLiveNation {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"LiveNation" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 23, [NSString stringWithFormat:@"Found %d of 23 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testPicasa {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Picasa" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 69, [NSString stringWithFormat:@"Found %d of 69 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 69, [NSString stringWithFormat:@"Found %d of 69 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testPosterous {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Posterous" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 17, [NSString stringWithFormat:@"Found %d of 17 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testStumbleUpon {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"StumbleUpon" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTumblr {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Tumblr" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 19, [NSString stringWithFormat:@"Found %d of 19 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTweetMeme {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"TweetMeme" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTwitPic {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"TwitPic" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 25, [NSString stringWithFormat:@"Found %d of 25 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testTwitterUserTimeline {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Twitter_User_Timeline" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 20, [NSString stringWithFormat:@"Found %d of 20 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testVimeo {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Vimeo" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 11, [NSString stringWithFormat:@"Found %d of 11 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 11, [NSString stringWithFormat:@"Found %d of 11 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testWeather {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Weather" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 7, [NSString stringWithFormat:@"Found %d of 7 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 1, [NSString stringWithFormat:@"Found %d of 1 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testWordPress {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"WordPress" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.content, [NSString stringWithFormat:@"Entry #%d has no \"content\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testYahooGroups {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Yahoo_Groups" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 15, [NSString stringWithFormat:@"Found %d of 15 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testYahooPipes {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Yahoo_Pipes" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 10, [NSString stringWithFormat:@"Found %d of 10 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 10, [NSString stringWithFormat:@"Found %d of 10 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testYelp {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"Yelp" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 5, [NSString stringWithFormat:@"Found %d of 5 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 0, [NSString stringWithFormat:@"Found %d of 0 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}

-(void)testYouTube {
	
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"YouTube" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
	FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	Feed *parsedFeed = [parser startProcessingData];
	int thumbnailCount = 0;
	int entryCount = 1;
	
	STAssertTrue([[parsedFeed entries] count] == 25, [NSString stringWithFormat:@"Found %d of 25 entries in this feed: %@",[[parsedFeed entries] count],path]);

	for(Entry *entry in [parsedFeed entries])
	{
		STAssertNotNil(entry.author, [NSString stringWithFormat:@"Entry #%d has no \"author\" data",entryCount]);
		STAssertNotNil(entry.formattedDescription, [NSString stringWithFormat:@"Entry #%d has no \"formattedDescription\" data",entryCount]);
		STAssertNotNil(entry.guid, [NSString stringWithFormat:@"Entry #%d has no \"guid\" data",entryCount]);
		STAssertTrue([entry.links count] > 0, [NSString stringWithFormat:@"Entry #%d has no \"links\"",entryCount]);
		STAssertNotNil(entry.summary, [NSString stringWithFormat:@"Entry #%d has no \"summary\" data",entryCount]);
		STAssertNotNil(entry.thumbnailURL, [NSString stringWithFormat:@"Entry #%d has no \"thumbnail\" data",entryCount]);
		STAssertNotNil(entry.title, [NSString stringWithFormat:@"Entry #%d has no \"title\" data",entryCount]);
		STAssertNotNil(entry.updated, [NSString stringWithFormat:@"Entry #%d has no \"updated\" data",entryCount]);
		
		if(entry.thumbnailURL != nil)
			thumbnailCount++;
		
		entryCount++;
	}
	
	STAssertTrue(thumbnailCount == 25, [NSString stringWithFormat:@"Found %d of 25 entries with thumbnails in this feed: %@",thumbnailCount,path]);
}


//-(void)testMergeFeed 
//{
//	//Merge should alwasy copy entries from feed #2 to feed #1 in all cases except:
//	//1.) When maximum number of entries has been bet.
//	//2.) 
//	
//	
//	//=================  Test Basic Merge Feed =====================
//	
//	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//	NSString *path1 = [bundle pathForResource:@"Yahoo_Pipes_MergeFeedTest_1" ofType:@"txt"];
//	NSString *path2 = [bundle pathForResource:@"Yahoo_Pipes_MergeFeedTest_2" ofType:@"txt"];
//	
//	NSURL *url1 = [NSURL fileURLWithPath:path1];
//	NSURL *url2 = [NSURL fileURLWithPath:path2];
//	
//	NSMutableData *itemsData1 = [[NSMutableData alloc] initWithContentsOfURL:url1];
//	NSMutableData *itemsData2 = [[NSMutableData alloc] initWithContentsOfURL:url2];
//	
//	FeedParser * parser1 = [[FeedParser alloc] initWithData:itemsData1];  //This feed should have 8 entries.
//	Feed * parsedFeed1 = [parser1 startProcessingData];
//	parsedFeed1.url = path1;
//	[parser1 release];
//	
//	
//	FeedParser *parser2 = [[FeedParser alloc] initWithData:itemsData2];  //This feed should have 10 entries.
//	Feed *parsedFeed2 = [parser2 startProcessingData];
//	parsedFeed2.url = path1;
//	[parser2 release];
//	
//	
//	
//	int numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 8,[NSString stringWithFormat:@"Number of entries for feed 1 is %i, it should be 8.", numberOfEntries1]);
//	
//	int numberOfEntries2 = [[parsedFeed2 entries]count];
//	STAssertTrue(numberOfEntries2 == 10, [NSString stringWithFormat:@"Number of entries for feed #2  is %i, it should be 10.", numberOfEntries2]);
//	
//	[FeedService mergeOldFeed:parsedFeed2 withNewFeed:parsedFeed1];
//
//	
//	int numberOfEntries_after_merge_1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries_after_merge_1 == 10, [NSString stringWithFormat:@"Number of entries for feed #1 is %i, it should be 10.", numberOfEntries_after_merge_1]);
//	
//	int numberOfEntries_after_merge_2 = [[parsedFeed2 entries]count];
//	STAssertTrue(numberOfEntries_after_merge_2 == 0, [NSString stringWithFormat:@"Number of entries for feed #2 is %i, it should be 0.", numberOfEntries_after_merge_2]);
//	[parsedFeed1 release];
//	[parsedFeed2 release];
//	
//	
//	//=================  Test Merge with Max Entries=====================	
//
//	maxEntries = 7;
//	
//	parser1 = [[FeedParser alloc] initWithData:itemsData1];  //This feed should have 7 entries.
//	parsedFeed1 = [parser1 startProcessingData];
//	parsedFeed1.url = path1;
//	[parser1 release];
//	
//	maxEntries = 100;
//	parser2 = [[FeedParser alloc] initWithData:itemsData2];  //This feed should have 10 entries.
//	parsedFeed2 = [parser2 startProcessingData];
//	parsedFeed2.url = path1;
//	[parser2 release];
//	
//	numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 7,[NSString stringWithFormat:@"Number of entries for feed 1 is %i, it should be 7.", numberOfEntries1]);
//	
//	
//	NSArray * entries2 = [parsedFeed2 entriesInOriginalOrder];
//	
//	numberOfEntries2 = [entries2 count];
//	STAssertTrue(numberOfEntries2 == 10, [NSString stringWithFormat:@"Number of entries for feed #2  is %i, it should be 10.", numberOfEntries2]);
//	
//	//Test to make sure that Feed two entries were placed at the end of Feed 1's entries.  
//	Entry * entry1ForFeed2 = [entries2 objectAtIndex:7];
//	int entry1ForFeed2_order =  [entry1ForFeed2.order intValue];
//	NSString * entry1ForFeed2_guid = [entry1ForFeed2.guid copy];
//	STAssertTrue(entry1ForFeed2_order == 7, [NSString stringWithFormat:@"First entry of Feed #2 should have an order value of 0"]);
//	
//	
//	maxStories = 8;
//	[FeedService mergeOldFeed:parsedFeed2 withNewFeed:parsedFeed1];
//	
//	
//	numberOfEntries_after_merge_1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries_after_merge_1 == 8, [NSString stringWithFormat:@"Number of entries for feed #1 is %i, it should be 8.", numberOfEntries_after_merge_1]);
//	
//	numberOfEntries_after_merge_2 = [[parsedFeed2 entries]count];
//	STAssertTrue(numberOfEntries_after_merge_2 == 0, [NSString stringWithFormat:@"Number of entries for feed #2 is %i, it should be 0.", numberOfEntries_after_merge_2]);
//	
//	Entry * LastEntryForFeed1 = [[parsedFeed1 entriesInOriginalOrder] objectAtIndex:7];
//	STAssertTrue([LastEntryForFeed1.order intValue] == 7, [NSString stringWithFormat:@"Last entry of Feed #1 should have an order value of 7"]);	
//	STAssertTrue([LastEntryForFeed1.guid isEqualToString:entry1ForFeed2_guid] , [NSString stringWithFormat:@"Last entry of Feed #1 is not equal to the guid of string 2"]);	
//																												  
//    [parsedFeed1 release];
//	[parsedFeed2 release];
//	
//}

//-(void)testMergeFeed 
//{
//	//Merge should alwasy copy entries from feed #2 to feed #1 in all cases except:
//	//1.) When maximum number of entries has been bet.
//	//2.) 
//	
//	
//	//=================  Test Basic Merge Feed =====================
//	
//	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//	NSString * feedKey = @"Yahoo_Pipes_MergeFeedTest_1";
//	NSString *path1 = [bundle pathForResource:@"Yahoo_Pipes_MergeFeedTest_1" ofType:@"txt"];
//	NSString *path2 = [bundle pathForResource:@"Yahoo_Pipes_MergeFeedTest_2" ofType:@"txt"];
//	
//	NSURL *url1 = [NSURL fileURLWithPath:path1];
//	NSURL *url2 = [NSURL fileURLWithPath:path2];
//	
//	NSMutableData *itemsData1 = [[NSMutableData alloc] initWithContentsOfURL:url1];
//	NSMutableData *itemsData2 = [[NSMutableData alloc] initWithContentsOfURL:url2];
//	
//	FeedParser * parser1 = [[FeedParser alloc] initWithData:itemsData1];  //This feed should have 8 entries.
//	parser1.feedKey = feedKey;
//	parser1.feedURL = path1;
//	
//	Feed * parsedFeed1 = [parser1 startProcessingData];
//	[parser1.objectStore save];
//	
//	
//	int numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 8,[NSString stringWithFormat:@"Number of entries for feed #1 is %i, it should be 8.", numberOfEntries1]);
//		
//	FeedParser *parser2 = [[FeedParser alloc] initWithData:itemsData2];  //This feed should have 10 entries.
//	parser2.feedKey = feedKey;
//	parser2.feedURL = path1;
//	
//	Feed *parsedFeed2 = [parser2 startProcessingData];
//	[parser2.objectStore save];
//	
//	
//	
//	int numberOfEntries2 = [[parsedFeed2 entries]count];
//	STAssertTrue(numberOfEntries2 == 10, [NSString stringWithFormat:@"Number of entries for feed #2  is %i, it should be 10.", numberOfEntries2]);
//	
//	BOOL parsedFeed1Status = [parsedFeed1 isDeleted];
//	[[parsedFeed1 managedObjectContext] refreshObject:parsedFeed1 mergeChanges:YES];
//    parsedFeed1Status = [parsedFeed1 isDeleted];
//	
//	numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 10,[NSString stringWithFormat:@"Number of entries for feed #1 is %i, it should now be 10.", numberOfEntries1]);
//	
//	[parser1 release];
//	[parser2 release];
//	
//	//=================  Test Merge with Max Entries=====================	
//	
//	int oldMaxEntries = maxEntries;
//    maxEntries = 6;
//	
//	parser1 = [[FeedParser alloc] initWithData:itemsData1];  //This feed should have 7 entries.
//	parser1.feedKey = feedKey;
//	parser1.feedURL = path1;
//	
//	parsedFeed1 = [parser1 startProcessingData];
//	[parser1.objectStore save];
//	
//	numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 6,[NSString stringWithFormat:@"Number of entries for feed 1 is %i, it should be 6.", numberOfEntries1]);
//     
//	Entry * lastEntry = [[parsedFeed1 entriesInOriginalOrder]objectAtIndex:5];
//	
//	NSInteger lastEntryOrderNumber = [lastEntry.order intValue];
//	STAssertTrue(lastEntryOrderNumber == 5,[NSString stringWithFormat:@"last entry order number shoulde be 5.", numberOfEntries1]);
//
//	
//	
//	maxEntries = 8;
//	parser2 = [[FeedParser alloc] initWithData:itemsData2];  //This feed should have 8 entries.
//	parser2.feedKey = feedKey;
//	parser2.feedURL = path1;
//
//	parsedFeed2 = [parser2 startProcessingData];
//	[parser2.objectStore save];
//	
//	NSArray * entries2 = [parsedFeed2 entriesInOriginalOrder];
//	
//	numberOfEntries2 = [entries2 count];
//	STAssertTrue(numberOfEntries2 == 8, [NSString stringWithFormat:@"Number of entries for feed #2  is %i, it should be 8.", numberOfEntries2]);
//	
//	[[parsedFeed1 managedObjectContext] refreshObject:parsedFeed1 mergeChanges:NO];
//	
//	numberOfEntries1 = [[parsedFeed1 entries]count];
//	STAssertTrue(numberOfEntries1 == 8,[NSString stringWithFormat:@"Number of entries for feed #1 is %i, it should now be 8.", numberOfEntries1]);
//	
//	[[lastEntry managedObjectContext] refreshObject:lastEntry mergeChanges:NO];
//	lastEntryOrderNumber = [lastEntry.order intValue];
//	STAssertTrue(lastEntryOrderNumber == 5,[NSString stringWithFormat:@"last entry order number should still be 5.", numberOfEntries1]);
//	
//	[parser1 release];
//	[parser2 release];
//
//    maxEntries = oldMaxEntries;
//}

-(void)testBlankFeeds {
       
    //save feed entries to DB
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:@"BlankFeed" ofType:@""];
	NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
	NSMutableData *itemsData = [[NSMutableData alloc] initWithContentsOfURL:url];
    
    NSString *feedUrlString = @"http://sdms2012.wordpress.com/category/general-information/feed";
    NSString *feedKey = @"n0";
    NSString * feedType = @"rss";
    
    FeedParser *parser = [[FeedParser alloc] initWithData:itemsData];
	
    parser.feedKey = feedKey;
    parser.feedURL = feedUrlString;
    
    DataStore * feedStore = [[DataStore alloc]init];
    parser.objectStore = feedStore;
    
    Feed *newFeed = [[parser startProcessingData] retain];
    [parser release];
    
    newFeed.moduleType  = feedType;
    
    [feedStore save];
    [feedStore release];
    
    [newFeed release];

    //retrieve items and check quantity
    
    FeedService *myFeedService = [[FeedService alloc] init];
    //Get cached feed from default store and ensure that the object state is up-to-date
    newFeed = (Feed *)[[myFeedService localDataStore] retrieveSingleEntityForClass:[Feed class] withValue:feedKey forAttribute:@"key"];
    
    NSInteger numberOfEntries = [[newFeed entries] count];
    
    NSLog(@"entries number = %d", numberOfEntries);
    
    STAssertTrue(numberOfEntries != 0,[NSString stringWithFormat:@"entry number of entires should not be 0, current value = %d\n", numberOfEntries]);
    
    [myFeedService release];
}

@end
