//
//  AppMakrClusterAnnotation.h
//  appbuildr
//
//  Created by Fawad Haider  on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AppMakrClusterer.h"
#import "Activity.h"
#import "AppMakrPinView.h"

@interface AppMakrClusterAnnotation : NSObject<MKAnnotation> {
 
    double           centerLatitude;
    double           centerLongitude;  
    NSMutableArray   *activities;
    
    AppMakrClusterer *clusterer; //The annotations in the cluster
    MKMapView        *mapView; // The mapview the cluster is appearing on.
    
    AppMakrPinView*  pinView;
    
    CGRect           animateFromFrame;
    CGRect           animateToFrame;
}

@property (nonatomic, assign) CGRect           animateFromFrame;
@property (nonatomic, assign) CGRect           animateToFrame;
@property (nonatomic, assign) AppMakrPinView   *pinView;

@property (nonatomic, retain) AppMakrClusterer *clusterer;
@property (nonatomic, retain) MKMapView        *mapView;
@property (nonatomic, retain) NSMutableArray   *activities;
@property double centerLatitude;
@property double centerLongitude;


-(id)initWithAnnotationClusterer:(AppMakrClusterer*) clusterManager;
-(void)addActivity: (Activity*) activity;
-(BOOL)removeActivity:(Activity*) activity;
-(int)totalActivities;
@end
