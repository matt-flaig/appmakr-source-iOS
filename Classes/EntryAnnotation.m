//
//  StoryAnnotation.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/8/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "EntryAnnotation.h"
#import "EntryGeoPoint.h"
#import "GeoPoint.h"
#import "RegexKitLite.h"


@implementation EntryAnnotation

@synthesize entryIndex;

- (void)dealloc
{
	[entry release];
    [super dealloc];
}
-(id) initWithEntry:(Entry *)aEntry 
{
	if( (self = [super init]) ) {
		entry = [aEntry retain];
	}
	return self;
}


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [entry.geoPoint.lat floatValue];
    theCoordinate.longitude = [entry.geoPoint.lng floatValue];
    return theCoordinate; 
}


- (NSString *)title 
{
    return entry.title;
}

// optional
- (NSString *)subtitle
{
	NSString * cleanSummary = [[entry.summary stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@" "] 
							   stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@" "] ;

	//Alternative solution if we want to preserve the text in the CDATA sections
/*	NSString * cleanSummary = [[[[entry.summary stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@" "] 
								 stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@" "] 
								stringByReplacingOccurrencesOfString:@"<![CDATA" withString:@" "]
							   stringByReplacingOccurrencesOfString:@"]]>" withString:@" "];
*/	return cleanSummary;	
}
@end
