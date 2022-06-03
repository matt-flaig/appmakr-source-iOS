//
//  AppMakrClusterer.h
//  appbuildr
//
//  Created by Fawad Haider  on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Activity.h"


//@class AppMakrClusterAnnotation;
@interface AppMakrClusterer : NSObject {
    NSMutableArray  *clusters; //Annotations in a cluster.
    MKMapView       *mapView;
    int             gridSize; //size of the annotation cluster in pixels on the map.
}

@property(nonatomic,retain) MKMapView *mapView;
@property(nonatomic,retain) NSMutableArray *clusters;

- (id)initWithMapAndAnnotations:(MKMapView *)mapView;

-(id<MKAnnotation>) addActivity:(Activity*)activity animateFromCluster:(id<MKAnnotation>)clusterAnnotation;

// Add |annotations| to the map and clusterer
-(void) addActivities:(NSArray*) activities;

// Remove all annotations from the clusterer
-(void) removeActivities;

// Total number of clusters that exist.
-(int) totalClusters;

// Total number annotations
-(int) totalActivities;

-(void)reCalculateForMerging;
-(void)reCalculateForSplitting;



@end
