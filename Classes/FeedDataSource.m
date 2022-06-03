//
//  FeedDataSource.m
//  appbuildr
//
//  Created by Nitin Alabur on 2/11/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "appbuildrAppDelegate.h"
#import "FeedDataSource.h"
#import "VarietyTableCell.h"
#import "GlobalVariables.h"
#import "FeedTableViewController.h"
#import "Feed.h"
#import "Feed+Extensions.h"
#import "Entry.h"
#import "AppMakrURLDownload.h"
#import "FeedArchiver.h"



@implementation FeedDataSource

@synthesize archivePath;


- (void)dealloc {
	[tableViewController release];
	[super dealloc];
}

-(id)initWithFeedTableViewController:(FeedTableViewController *)feedViewController{
	if( (self = [super init]) ) {
		tableViewController = [feedViewController retain];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	DebugLog(@"return count:%i", [tableViewController.feed.entries count]);
	return [tableViewController.feed.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)newTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	int storyIndex = [indexPath indexAtPosition: [indexPath length] -1];
	
	VarietyTableCell *cell = (VarietyTableCell *)[newTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		// GlobalVariables* global = [GlobalVariables getPlist];				
		//NSDictionary *fontDict = (NSDictionary *)[global objectForKey:@"row_font_color"];
		
		UIColor *titleColor = nil;
		NSDictionary *rowTitleDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
		if( rowTitleDict ) {
			CGFloat rowTitleRed = [(NSNumber *)[rowTitleDict objectForKey:@"row_title_red"] floatValue]/255.0f;
			CGFloat rowTitleGreen =[(NSNumber *)[rowTitleDict objectForKey:@"row_title_green"] floatValue]/255.0f;
			CGFloat rowTitleBlue = [(NSNumber *)[rowTitleDict objectForKey:@"row_title_blue"] floatValue]/255.0f;
			titleColor = [UIColor colorWithRed:rowTitleRed green:rowTitleGreen blue:rowTitleBlue alpha:1.0f];
		}
		UIColor *descColor = nil;
		NSDictionary *rowDescDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
		if( rowDescDict ) {
			CGFloat rowDescRed = [(NSNumber *)[rowDescDict objectForKey:@"row_desc_red"] floatValue]/255.0f;
			CGFloat rowDescGreen =[(NSNumber *)[rowDescDict objectForKey:@"row_desc_green"] floatValue]/255.0f;
			CGFloat rowDescBlue = [(NSNumber *)[rowDescDict objectForKey:@"row_desc_blue"] floatValue]/255.0f;
			descColor = [UIColor colorWithRed:rowDescRed green:rowDescGreen blue:rowDescBlue alpha:1.0f];
		}	
		cell = [[[VarietyTableCell alloc] initWithStyle:UITableViewCellStyleDefault 
											 titleColor:titleColor
											  descColor:descColor
										reuseIdentifier:MyIdentifier] autorelease];	
        
        cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        cell.selectedBackgroundView.backgroundColor = [UIColor blueColor];
	}
	
	Feed * localFeed = (Feed*) tableViewController.feed;
	Entry *entry = [[localFeed entriesInOriginalOrder] objectAtIndex:storyIndex];

	//DOWNLOAD THE IMAGE IF THERE IS URL AND THERE IS NO VIEW ASSOCIATED WITH THE URL
	if (entry.thumbnailURL && !entry.thumbnailImage) 
	{
		[tableViewController.theFeedService fetchThumbnailForEntry:entry];		
	}
	
	//theFeedService
    if (entry)
        [cell setupCellWithEntry:entry withIndention:[tableViewController.tableView isEditing]];
	return cell;
}

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return NO;
}


@end
