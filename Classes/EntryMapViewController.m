//
//  EntryMapViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "EntryMapViewController.h"
#import "EntryGeoPoint.h"
#import "GeoPoint.h"
#import "EntryViewController.h"
#import "EntryAnnotation.h"
#import "UserAnnotation.h"
#import "FeedObjects.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@implementation EntryMapViewController
@synthesize mapView;
@synthesize theService;
- (void) dealloc {
	[localEntry release];
	[self.mapView removeFromSuperview]; 
	/* this is a bug fix.  it requires me to remove it from the superview before releasing it */
	[mapView release];
	[feed release];
	[userLocation release];
	[super dealloc];
}
- (id)initWithFeed:(Feed *)newFeed userLocation:(CLLocation *)theUserLocation storyIndex:(NSInteger)clickedStoryIndex 
{
	if( (self = [super init]) ) {
		feed  = [newFeed retain];
		storyIndex = clickedStoryIndex;
		userLocation = [theUserLocation retain];
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (id)initWithFeed:(Feed *)newFeed userLocation:(CLLocation *)theUserLocation
{
	return [self initWithFeed:newFeed userLocation:theUserLocation storyIndex:-1];
}

- (id)initWithEntry:(Entry *)myentry userLocation:(CLLocation *)theUserLocation
{
	if( (self = [super init]) ) {
		feed = nil;
		localEntry = [myentry retain];
		userLocation = [theUserLocation retain];
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}


- (id)initWithFeedID:(id)objectID userLocation:(CLLocation *)theUserLocation storyIndex:(NSInteger)clickedStoryIndex
{
	AppMakrSocializeService *currentService = [[AppMakrSocializeService alloc] init];
	self.theService = currentService;
	self.theService.delegate = self;
	[currentService release];
		
	Feed * newFeed = (Feed *) [theService.localDataStore entityWithID:objectID];
	return [self initWithFeed:newFeed userLocation:theUserLocation storyIndex:-1];
}

- (id)initWithFeedID:(id)objectID userLocation:(CLLocation *)theUserLocation
{
	return [self initWithFeedID:objectID userLocation:theUserLocation storyIndex:-1];
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}
#pragma mark view controller callbacks
- (void)viewWillAppear:(BOOL)animated {
	[self resize];
	[super viewWillAppear:animated];
}

-(void)resize {
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		self.view.frame = CGRectMake(0, 0, 480, 206);
		self.navigationController.navigationBar.hidden = NO;
	}
}
	
- (void) addEntryAnnotations
{
	NSArray * entryArray = [feed entriesInOriginalOrder];
	Entry * firstEntry = (Entry *) [entryArray objectAtIndex:0];
	CGFloat maxLongitude = [firstEntry.geoPoint.lng floatValue];
	CGFloat minLongitude = maxLongitude;
	
	CGFloat maxLatitude = [firstEntry.geoPoint.lat floatValue];
	CGFloat minLatitude = maxLatitude;
	
	
	//WMJ 8-12-2010:This is probably not efficent.  But let's do this the simple way for now.
	//I can pretty much garauntee there is a better way.
	
	if (feed){
		if (storyIndex == -1)
		{
			
			int entryCount = [entryArray count];
			for (int i=0; i<entryCount; i++) 
			{
				Entry * entry = [entryArray objectAtIndex:i];	
				
				maxLongitude = fmax(maxLongitude, [entry.geoPoint.lng floatValue]);
				maxLatitude = fmax(maxLatitude, [entry.geoPoint.lat floatValue]);
				
				minLongitude = fmin(minLongitude, [entry.geoPoint.lng floatValue]);
				minLatitude = fmin(minLatitude, [entry.geoPoint.lat floatValue]);
				
				DebugLog(@"placing pin for entry here: %f %f", entry.geoPoint.lat, entry.geoPoint.lng);
				EntryAnnotation * entryAnnotation = [[[EntryAnnotation alloc] initWithEntry:entry] autorelease];
				entryAnnotation.entryIndex = i;   //used for the button tag of the Annotation view
				[self.mapView addAnnotation:entryAnnotation];
			}
		}
		else 	
		{
			Entry * entry = [entryArray objectAtIndex:storyIndex];	
			
			maxLongitude = fmax(maxLongitude, [entry.geoPoint.lng floatValue]);
			maxLatitude = fmax(maxLatitude, [entry.geoPoint.lat floatValue]);
			
			minLongitude = fmin(minLongitude, [entry.geoPoint.lng floatValue]);
			minLatitude = fmin(minLatitude, [entry.geoPoint.lat floatValue]);
			
			DebugLog(@"placing pin for entry here: %f %f", entry.geoPoint.lat, entry.geoPoint.lng);
			EntryAnnotation * entryAnnotation = [[[EntryAnnotation alloc] initWithEntry:entry] autorelease];
			entryAnnotation.entryIndex = storyIndex;   //used for the button tag of the Annotation view
			[self.mapView addAnnotation:entryAnnotation];
		}
	}
	else if (localEntry) {
		maxLongitude = fmax(maxLongitude, [localEntry.geoPoint.lng floatValue]);
		maxLatitude = fmax(maxLatitude, [localEntry.geoPoint.lat floatValue]);
		
		minLongitude = fmin(minLongitude, [localEntry.geoPoint.lng floatValue]);
		minLatitude = fmin(minLatitude, [localEntry.geoPoint.lat floatValue]);
		
		DebugLog(@"placing pin for entry here: %f %f", localEntry.geoPoint.lat, localEntry.geoPoint.lng);
		EntryAnnotation * entryAnnotation = [[[EntryAnnotation alloc] initWithEntry:localEntry] autorelease];
		entryAnnotation.entryIndex = storyIndex;   //used for the button tag of the Annotation view
		[self.mapView addAnnotation:entryAnnotation];
	}

	
	CLLocationCoordinate2D topLeftCoord;    
    CLLocationCoordinate2D bottomRightCoord;
	
	topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
	
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
	
	topLeftCoord.longitude = fmin(userLocation.coordinate.longitude, minLongitude);
	topLeftCoord.latitude = fmax(userLocation.coordinate.latitude, maxLatitude);
	
	DebugLog(@"placing pin for top left : %f %f", topLeftCoord.latitude, topLeftCoord.longitude);
	bottomRightCoord.longitude = fmax(userLocation.coordinate.longitude, maxLongitude);
	bottomRightCoord.latitude = fmin(userLocation.coordinate.latitude, minLatitude );
	
	DebugLog(@"placing pin for bottom right : %f %f", bottomRightCoord.latitude, bottomRightCoord.longitude);

	//WMJ 8-12-2010: This method should return the region instead of adding it to the Map Directly.  But this is fine for now.
	MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
	region = [mapView regionThatFits:region];
	self.mapView.region = region;
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	
	MKMapView * aMapView = [[MKMapView alloc] init];
	self.mapView = aMapView;
	[aMapView release];
	
	self.mapView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.mapView.delegate = self;
	[self.view addSubview:mapView];
    if([[feed entriesInOriginalOrder] count]>0)
        [self addEntryAnnotations];
		
   	DebugLog(@"placing pin for user here: %f %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
	UserAnnotation * userAnnotation = [[UserAnnotation alloc] initWithLocation:userLocation];
	[self.mapView addAnnotation:userAnnotation];
	[userAnnotation release];
	
}



-(void) viewDidUnload {
	//self.mapView = nil;
	[super viewDidUnload];
}
#pragma mark map view delegate callbacks
- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
	// try to dequeue an existing pin view first

	if ([annotation isKindOfClass:[UserAnnotation class]]) { 
		static NSString* userAnnotationIdentifier = @"userAnnotationIdentifier";		
		MKPinAnnotationView* pinView = (MKPinAnnotationView *) [aMapView dequeueReusableAnnotationViewWithIdentifier:userAnnotationIdentifier];
		
		if (!pinView)
		{
			// if an existing pin view was not available, create one
			MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:userAnnotationIdentifier] autorelease];
			customPinView.pinColor = MKPinAnnotationColorRed;
			customPinView.animatesDrop = YES;
			customPinView.canShowCallout = YES;
			return customPinView;	
		} 
		return pinView;
	}
	else {
		static NSString* entryAnnotationIdentifier = @"entryAnnotationIdentifier";		
		MKPinAnnotationView* pinView = (MKPinAnnotationView *) [aMapView dequeueReusableAnnotationViewWithIdentifier:entryAnnotationIdentifier];		
		if (!pinView)
		{
			EntryAnnotation * ea = (EntryAnnotation *)annotation;
			
			// if an existing pin view was not available, create one
			MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:entryAnnotationIdentifier] autorelease];
			customPinView.pinColor = MKPinAnnotationColorPurple;
			customPinView.animatesDrop = YES;
			customPinView.canShowCallout = YES;
			UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			rightButton.tag = ea.entryIndex;
			[rightButton addTarget:self action:@selector(rightCalloutClicked:) forControlEvents:UIControlEventTouchUpInside];
			customPinView.rightCalloutAccessoryView = rightButton;
			return customPinView;	
		} 
		return pinView;
	}
}

- (void) rightCalloutClicked:(id)button {
	DebugLog(@"right callout clicked!  adding more to the navigation");	
	// create a new ViewController called DescriptionViewController and push it over the RootViewController
	UIButton * annotationButton = (UIButton *)button;

    Entry* entry = [[feed entriesInOriginalOrder] objectAtIndex:annotationButton.tag];
    EntryViewController* descController = [[EntryViewController alloc] initWithEntryID:entry.objectID];

	//EntryViewController* descController = [[EntryViewController alloc] initWithFeed:feed storyIndex:annotationButton.tag showMediaPlayer:NO];
	//descController.changePageButton = changePageButton;
	[self.navigationController pushViewController:descController animated:YES];
	[descController release];
	
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
