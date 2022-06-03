//
//  EntryMapViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//


#import <MapKit/MapKit.h>
#import "Feed.h"
#import "AppMakrSocializeService.h"

@interface EntryMapViewController : UIViewController<MKMapViewDelegate, AppMakrSocializeServiceDelegate>  
{
	Entry		*localEntry;
	Feed		*feed;
	NSInteger	storyIndex;
	CLLocation	*userLocation;
	MKMapView	*mapView;
	AppMakrSocializeService *theService;
}
@property(nonatomic, retain) MKMapView * mapView;
@property(nonatomic, retain) AppMakrSocializeService   *theService;

- (id)initWithFeed:(Feed *)newFeed userLocation:(CLLocation *)theUserLocation storyIndex:(NSInteger)clickedStoryIndex;
- (id)initWithFeed:(Feed *)newFeed userLocation:(CLLocation *)theUserLocation;

- (id)initWithFeedID:(id)objectID userLocation:(CLLocation *)theUserLocation storyIndex:(NSInteger)clickedStoryIndex;
- (id)initWithFeedID:(id)objectID userLocation:(CLLocation *)theUserLocation;
- (id)initWithEntry:(Entry *)entry userLocation:(CLLocation *)theUserLocation;

- (void)resize;

@end
