//
//  UserAnnotion.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/10/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "UserAnnotation.h"


@implementation UserAnnotation


- (void)dealloc
{
	[userLocation release];
    [super dealloc];
}
-(id) initWithLocation:(CLLocation *)location;
{
	if( (self = [super init]) ) {
		userLocation = [location retain];
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate;
{
	return userLocation.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate;
{
    [userLocation release];
    userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [userLocation retain];
}

- (NSString *)title 
{
    return @"Your Location";
}
@end
