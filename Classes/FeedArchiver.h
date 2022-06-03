//
//  FeedArchiver.h
//  appbuildr
//
//  Created by Isaac Mosquera on 10/5/09.
//  Copyright 2009 pointabout. All rights reserved.
//
#import "Feed.h"

@interface FeedArchiver : NSObject {
	
	Feed * feed;
	NSString * title;
}
@property(nonatomic, retain) Feed * feed;
- (void) archiveWithFeed:(Feed *)newFeed title:(NSString *)aTitle;
- (Feed *) unarchiveWithTitle:(NSString*) title;
+ (void) removeAllArchivedData;
@end
