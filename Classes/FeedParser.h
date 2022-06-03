//
//  FeedParser.h
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "CXMLDocument.h"

@class DataStore;
@interface FeedParser : NSObject {
	// added for ensuring there are no mutable objects for storing in NSUIserdefaults. Copy items into itemsArray
	NSMutableData *itemsData;
	NSString * feedURL;
	NSString * feedKey;
	NSObject *object;
	NSStringEncoding stringEncoding;
	BOOL knownFeedLength;
	float feedTotal;
	float feedDone;
	
	NSTimer *timeout;
	
	DataStore * objectStore;
}

@property(nonatomic,retain) NSString * feedURL;
@property(nonatomic,retain) NSString * feedKey;
@property(assign) BOOL knownFeedLength;
@property(assign) float feedTotal;
@property(assign) float feedDone;
@property(nonatomic,retain) DataStore * objectStore;
-(id)initWithData:(NSMutableData *)data;
-(id)initWithURL:(NSString *)URL id:(NSObject *)calledObject;
-(void) parse;
- (void)timerFireMethod:(NSTimer*)theTimer;
-(Feed *)startProcessingData;
-(Feed *)parseDocument:(CXMLDocument *)document;
@end
