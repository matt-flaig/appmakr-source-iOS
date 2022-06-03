//
//  UserAnnotion.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/10/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject<MKAnnotation> {
	
	CLLocation * userLocation;
}

-(id) initWithLocation:(CLLocation *)location;
@end
