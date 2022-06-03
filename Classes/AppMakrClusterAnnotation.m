//
//  AppMakrClusterAnnotation.m
//  appbuildr
//
//  Created by Fawad Haider  on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrClusterAnnotation.h"
#import "Activity.h"
#import <UIKit/UIKit.h>

@implementation AppMakrClusterAnnotation

@synthesize clusterer, activities, centerLongitude, 
            centerLatitude, mapView, pinView, animateFromFrame, animateToFrame;

/*-(id) initWithLocation:(CLLocation *)location;
{
	if( (self = [super init]) ) {
		userLocation = [location retain];
	}
	return self;
}
*/

- (id)initWithAnnotationClusterer:(AppMakrClusterer*) clusterManager {
    
    if ((self = [super init])) {
        // Custom initialization
        activities = [NSMutableArray new];
        self.clusterer = clusterManager;
        self.mapView = clusterManager.mapView;
        centerLatitude = 0.0f;
        centerLongitude = 0.0f;
        
        
        animateFromFrame = CGRectZero;
        
    }
    
    return self;
    
}


- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = self.centerLatitude;
    theCoordinate.longitude = self.centerLongitude;
    return theCoordinate; 
}

/*- (CLLocationCoordinate2D)coordinate;
{
	return userLocation.coordinate;
}
*/
- (NSString *)title 
{
    if ([activities count]>1){
        return [NSString stringWithFormat:@"Activity Group %d",[activities count]];
    }
    else{
        Activity* activity = [activities objectAtIndex:0];
        if ( activity.text !=  nil) 
            if ( [activity.text length] > 0)
                return activity.text;
        return @"if Activity.text is nil";
    }
}

// optional
- (NSString *)subtitle
{
    if ([activities count]>1){
        return [NSString stringWithFormat:@"No of Activities  %d",[activities count]];
    }
    else{
        Activity* activity = [activities objectAtIndex:0];
        NSString * nameAndHourString = [NSString stringWithFormat:@"%@ about 10 hours ago",activity.username];
        return nameAndHourString;
    }
    return @"";
}


-(void) addActivity: (Activity*) activity {
    if(centerLatitude == 0.0 && centerLongitude == 0.0) {
      centerLatitude = [activity.myGeoPoint.lat doubleValue];
      centerLongitude = [activity.myGeoPoint.lng doubleValue];
            
    }
    [activities addObject:activity];
}


-(BOOL) removeActivity:(Activity*) myactivity {
    for(Activity* activity in activities) {
        if([activity isEqual:myactivity]) {
            [activities removeObject:activity];
            return YES;
        }
    }
    return NO;
}

- (int)totalActivities
{
	return [activities count];
}

-(void)dealloc{

	[mapView release];
	[clusterer release];
	[activities release];
    [super dealloc];
}

@end
