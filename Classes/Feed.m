// 
//  Feed.m
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import "Feed.h"

#import "Entry.h"
#import "FeedGeoPoint.h"
#import "FeedLink.h"

@implementation Feed 

@dynamic expirationDate;
@dynamic host;
@dynamic key;
@dynamic url;
@dynamic entries;
@dynamic links;
@dynamic geoPoint;
@dynamic moduleType;

-(void) dealloc {
	[super dealloc];
}
@end
