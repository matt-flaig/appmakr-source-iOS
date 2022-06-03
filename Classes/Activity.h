//
//  Activity.h
//  appbuildr
//
//  Created by William Johnson on 12/16/10.
//  Copyright 2010 pointabout. All rights reserved.
//
#import "GeoPoint.h"
#import "Entry.h"
#import "EntryComment+Extensions.h"
#import "MyGeoPoint.h"

typedef enum 
{
	ACTIVITY_TYPE_COMMENT =1,
	ACTIVITY_TYPE_SHARE_TWITTER,
	ACTIVITY_TYPE_SHARE_FACEBOOK,
	ACTIVITY_TYPE_SHARE_EMAIL, 
	ACTIVITY_TYPE_LIKE,
	ACTIVITY_TYPE_NEWUSER,	
} ActivityType;


@class Entry;
@class GeoPoint;
/*

@interface MyGeoPoint :  NSObject
{
    NSNumber * lat;
    NSNumber * lng;
}

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;

@end


@implementation MyGeoPoint

@synthesize lat;
@synthesize lng;

@end

*/
@interface Activity : NSObject 
{
	NSString * text;
	Entry * entry;
	NSString * applicationName;
	NSString * applicationId;
	NSString * username;
	NSString * userId;
	NSString * userImageURL;
	BOOL userImageDownloaded;
	GeoPoint * geoPoint;
	MyGeoPoint * newGeoPoint;
	NSDate * date;
	ActivityType type;
	UIImage * userProfileImage;
	NSString* url;
	
}

@property (nonatomic, assign) ActivityType type;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * applicationName;
@property (nonatomic, retain) NSString * applicationId;
@property (nonatomic, retain) NSString * userSmallImageURL;
@property (nonatomic, retain) NSString * userMediumImageURL;
@property (nonatomic, retain) NSString * userLargeImageURL;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userId;

@property (nonatomic )		  BOOL userImageDownloaded;
@property (nonatomic, retain) UIImage * userProfileImage;
@property (nonatomic, retain) NSDate * date;

@property (nonatomic, retain) GeoPoint * geoPoint;
@property (nonatomic, retain) MyGeoPoint * myGeoPoint;
@property (nonatomic, retain) Entry * entry;
@property (nonatomic, retain) NSString * url;

@end
