//
//  GeoPointParser.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "GeoParser.h"
#import "GeoPoint.h"
#import "DataStore.h"
#import "EntryGeoPoint.h"

@implementation GeoParser

@synthesize objectStore;

- (void) dealloc
{
	[objectStore release];
	[super dealloc];
}

-(NSObject*) createObjectOfClass:(Class)aClass
{
    return [objectStore createObjectOfClass:aClass];
}

-(void)parseGeoWithEntry:(Entry *)entry xmlElement:(CXMLElement *)xmlElement {
	
	NSString * lat = nil;
	NSString * lng = nil;
	if( [[xmlElement name] isEqualToString:@"lat" ] ) {	
		lat = [xmlElement stringValue];
	}
	if( [[xmlElement name] isEqualToString:@"long" ] ) {	
		lng = [xmlElement stringValue];
	}
	if( [[xmlElement name] isEqualToString:@"point" ] ) {	
		NSString * elementGeopoint = [[xmlElement stringValue]
									  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		DebugLog(@"####### POINT %@", elementGeopoint);
		// Note (By Fawad Haider )As per description here http://georss.org/simple commas can be usd as separators
		NSArray *values= [elementGeopoint componentsSeparatedByCharactersInSet:
						  [NSCharacterSet characterSetWithCharactersInString:@" ,"]];
		if ([values count] > 1){
			lat = [values objectAtIndex:0];
			lng = [values objectAtIndex:1];
		}
	}
	if ( (lat || lng) && !entry.geoPoint ) 
	{
		EntryGeoPoint * tmpGeoPoint = (EntryGeoPoint *) [self createObjectOfClass:[EntryGeoPoint class]];
		
		entry.geoPoint = tmpGeoPoint;
	}
	if( lat ) 
	{
		
		entry.geoPoint.lat = [NSNumber numberWithFloat:[lat floatValue]];
	}
	if( lng ) 
	{
		entry.geoPoint.lng = [NSNumber numberWithFloat:[lng floatValue]];	
	}
	
}
@end
