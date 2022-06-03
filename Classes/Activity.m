//
//  Activity.m
//  appbuildr
//
//  Created by William Johnson on 12/16/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Activity.h"


@implementation Activity

@synthesize type;
@synthesize text;
@synthesize title;
@synthesize applicationName;
@synthesize applicationId;
@synthesize userSmallImageURL;
@synthesize userMediumImageURL;
@synthesize userLargeImageURL;
@synthesize userImageDownloaded;
@synthesize userProfileImage;
@synthesize userId;
@synthesize username;
@synthesize date;
@synthesize geoPoint;
@synthesize myGeoPoint;
@synthesize entry;
@synthesize url;

-(void)dealloc
{
	[url release];
	
	[text release];
	[applicationName release];
	[applicationId release];
	[userImageURL release];
	[userProfileImage release];
	[userId release];
	[username release];
	[date release];
	[geoPoint release];
	[entry release];
	[super dealloc];
}


@end
