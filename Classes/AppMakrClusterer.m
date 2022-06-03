//
//  AppMakrClusterer.m
//  appbuildr
//
//  Created by Fawad Haider  on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrClusterer.h"
#import "Activity.h"
#import "AppMakrClusterAnnotation.h"

@implementation AppMakrClusterer

@synthesize clusters,mapView;

- (id)initWithMapAndAnnotations:(MKMapView *)paramMapView {
    
    if ((self = [super init])) {
        // Custom initialization
        gridSize = 10; //size of the annotation in pixels on the map
        clusters = [NSMutableArray new];
        self.mapView = paramMapView;
    }
    
    return self;
}


-(void)reCalculateForSplitting{

    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray* tmpClusterArray = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray* tmpArrayToAdd = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (AppMakrClusterAnnotation *arrayCluster in clusters){
        [tmpClusterArray addObject:arrayCluster];
    }
    
    for(AppMakrClusterAnnotation *arrayCluster in clusters) {
        if ([arrayCluster.activities count] > 1){
            for (Activity* activity in arrayCluster.activities) {

                CLLocationCoordinate2D location;
                location.latitude = [activity.myGeoPoint.lat doubleValue];
                location.longitude = [activity.myGeoPoint.lng doubleValue];
                
                CGPoint clusterCenterPoint = [self.mapView convertCoordinate:arrayCluster.coordinate toPointToView:self.mapView];

                CGPoint point = [self.mapView convertCoordinate:location toPointToView:self.mapView];
                if (point.x >= clusterCenterPoint.x - gridSize && point.x <= clusterCenterPoint.x + gridSize &&
                    point.y >= clusterCenterPoint.y - gridSize && point.y <= clusterCenterPoint.y + gridSize) {
                    
                }
                else{
                    // the activity needs to be removed from this cluster
                    [tmpArray addObject:activity];
                }
            }

            [arrayCluster.activities removeObjectsInArray:tmpArray];
            for(Activity* activity in tmpArray){
                
                CLLocationCoordinate2D location;
                location.latitude = [activity.myGeoPoint.lat doubleValue];
                location.longitude = [activity.myGeoPoint.lng doubleValue];
                BOOL activityAddedToCluster = NO;
                 
                CGPoint point = [self.mapView convertCoordinate:location toPointToView:self.mapView];
                AppMakrClusterAnnotation *cluster = nil;
                CGPoint clusterCenterPoint;

                for(AppMakrClusterAnnotation *arrayCluster in tmpClusterArray) {
                    if(arrayCluster.centerLatitude != 0.0 && arrayCluster.centerLongitude != 0.0) {
                        clusterCenterPoint = [self.mapView convertCoordinate:arrayCluster.coordinate toPointToView:self.mapView];
                        
                        // Found a cluster which contains the marker.
                        if (point.x >= clusterCenterPoint.x - gridSize && point.x <= clusterCenterPoint.x + gridSize &&
                            point.y >= clusterCenterPoint.y - gridSize && point.y <= clusterCenterPoint.y + gridSize) {
                            
                            [arrayCluster addActivity:activity];
                            activityAddedToCluster = YES;
                            break;
                        }      
                    } else {
                        continue;
                    }
                }
                 
                if (!activityAddedToCluster){
                    cluster = [[AppMakrClusterAnnotation alloc] initWithAnnotationClusterer:self];
                    [cluster addActivity:activity];
                    
                     if(arrayCluster.pinView){
                        cluster.animateFromFrame = arrayCluster.pinView.frame;
                     }
                     else{
                         CLLocationCoordinate2D location;
                         location.latitude = arrayCluster.centerLatitude ;
                         location.longitude = arrayCluster.centerLongitude;
                         CGPoint point = [self.mapView convertCoordinate:location toPointToView:self.mapView];
                         cluster.animateFromFrame = CGRectMake(point.x, point.y, 32, 39);
                     }

                    [tmpClusterArray addObject:cluster];
                    [tmpArrayToAdd addObject:cluster];
                    [cluster release];
                }
            }
        }
        [tmpArray removeAllObjects];
    //    [tmpArray release];
    }
    for (AppMakrClusterAnnotation* annotation in tmpArrayToAdd){
        
        [self performSelectorOnMainThread:@selector(addAnnotation:)
                               withObject:annotation
                            waitUntilDone:NO];        
        [clusters addObject:annotation];
    }
    //[clusters addObjectsFromArray:tmpClusterArray];
    [tmpArrayToAdd release];
    [tmpClusterArray release];
}

-(void)addAnnotation:(AppMakrClusterAnnotation*)annotation{
    [self.mapView addAnnotation:annotation];
}

-(void)reCalculateForMerging{
    BOOL needsBreaking = NO;
    AppMakrClusterAnnotation *annoatationToBeMerged1 = nil;
    AppMakrClusterAnnotation *annoatationToBeMerged2 =nil;
    
    for(AppMakrClusterAnnotation *arrayCluster1 in clusters) {
        annoatationToBeMerged1 =  arrayCluster1;
        for (AppMakrClusterAnnotation *arrayCluster2 in clusters) {
            annoatationToBeMerged2 = arrayCluster2;
            if (arrayCluster1 != arrayCluster2){

                CGPoint clusterCenterPoint1 = [self.mapView convertCoordinate:arrayCluster1.coordinate toPointToView:self.mapView];

                CGPoint clusterCenterPoint2 = [self.mapView convertCoordinate:arrayCluster2.coordinate toPointToView:self.mapView];
                
                if (clusterCenterPoint1.x >= clusterCenterPoint2.x - gridSize && clusterCenterPoint1.x <= clusterCenterPoint2.x + gridSize &&
                    clusterCenterPoint1.y >= clusterCenterPoint2.y - gridSize && clusterCenterPoint1.y <= clusterCenterPoint2.y + gridSize) {
                    needsBreaking = YES;
                    break;
                }
            }
        }
        if (needsBreaking)
            break;
    }
    if (needsBreaking){
        // we need to merge to annotations
        if(annoatationToBeMerged1.pinView){
            annoatationToBeMerged2.animateToFrame = annoatationToBeMerged1.pinView.frame;
        }

        [annoatationToBeMerged1.activities addObjectsFromArray:annoatationToBeMerged2.activities];
        [self performSelectorOnMainThread:@selector(removeAnnotation:)
         	                         withObject:annoatationToBeMerged2
         	                      waitUntilDone:NO];        
        [self.clusters removeObject:annoatationToBeMerged2]; 
        [self reCalculateForMerging];
    }
    return;
}

#define ANIMATION_DURATION 0.20

-(void)removeAnnotation:(AppMakrClusterAnnotation*)annotation{
    if (annotation.pinView){
        [UIView beginAnimations:@"removeAnnotation" context:annotation];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView  setAnimationDidStopSelector:@selector(mergeAnimationDidStop:finished:context:)];
        [annotation.pinView setFrame:annotation.animateToFrame];
        [UIView commitAnimations];
    }
    else
        [self.mapView removeAnnotation:annotation];
}


- (void)mergeAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeAnnotation"]){
        [self.mapView removeAnnotation:(id<MKAnnotation>)context];
    }
}

-(AppMakrClusterAnnotation*)addActivity:(Activity*)activity animateFromCluster:(AppMakrClusterAnnotation*)clusterAnnotation{
    
    CLLocationCoordinate2D location;
    location.latitude = [activity.myGeoPoint.lat doubleValue];
    location.longitude = [activity.myGeoPoint.lng doubleValue];
    
    CGPoint point = [self.mapView convertCoordinate:location toPointToView:self.mapView];
    AppMakrClusterAnnotation *cluster = nil;
    
    for(AppMakrClusterAnnotation *arrayCluster in clusters) {
        if(arrayCluster.centerLatitude != 0.0 && arrayCluster.centerLongitude != 0.0) {
            CGPoint clusterCenterPoint = [self.mapView convertCoordinate:arrayCluster.coordinate toPointToView:self.mapView];
            
            // Found a cluster which contains the marker.
            if (point.x >= clusterCenterPoint.x - gridSize && point.x <= clusterCenterPoint.x + gridSize &&
                point.y >= clusterCenterPoint.y - gridSize && point.y <= clusterCenterPoint.y + gridSize) {
                 
                [arrayCluster addActivity:activity];
                return nil;
            }      
        } else {
            continue;
        }
    }
    
    
    // No cluster contain the marker, create a new cluster.
    cluster = [[AppMakrClusterAnnotation alloc] initWithAnnotationClusterer:self];
    [cluster addActivity:activity];
    
    if(clusterAnnotation){
        if(clusterAnnotation.pinView){
            cluster.animateFromFrame = clusterAnnotation.pinView.frame;
        }
    }
    
    [self performSelectorOnMainThread:@selector(addAnnotation:)
                           withObject:cluster
                        waitUntilDone:YES];        

    // Add this cluster both in clusters provided and clusters_
    [clusters addObject:cluster];
    [cluster release];
    return cluster;
}

-(void) addActivities:(NSArray*) newActivities {
    for(Activity* anno in newActivities) {
        [self addActivity:anno animateFromCluster:nil];
    }
}

-(void) removeActivities {  
    [clusters removeAllObjects];
}

-(int) totalClusters {
    return [clusters count];
}

-(int) totalActivities {
    int result = 0;
    
    for(AppMakrClusterAnnotation *arrayCluster in clusters) {
        result += [arrayCluster totalActivities];
    }
    
    return result;
}

- (void)dealloc {
    [clusters release];
    [mapView release];
    [super dealloc];
}

@end
