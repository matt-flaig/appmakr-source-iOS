//
//  ActivityMapViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 4/26/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "ActivityMapViewController.h"
#import "ActivityViewController.h"
#import "EntryViewController.h"
#import "UIButton+Socialize.h"


#import "AccessorizedCalloutMapAnnotationView.h"
#import "TCImageView.h"
#import "AppMakrMapCalloutContentView.h"
#import "AppMakrNativeLocation.h"

@interface ActivityMapViewController(private)
-(void)addMapView;
-(float) MilesToMeters:(float) miles;
-(void)removeAnnotations;
-(void)startRequest;
-(MKCoordinateRegion)regionFromLocations;
-(NSString *)timeString:(NSDate *)date;
-(UIView*)prepareContentViewForCallout:(AppMakrClusterAnnotation*)cluster;
-(NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels;
-(UIBarButtonItem*) createLeftNavigationButtonWithCaption: (NSString*) caption;
@end

@implementation ActivityMapViewController

@synthesize theService;
@synthesize delegate;
@synthesize activitiesArray, mapIsDisplayed;

@synthesize mapView, operationQueue, userLocation;
@synthesize calloutAnnotation ;
@synthesize selectedAnnotationView ;
@synthesize olderCalloutAnnotation;


- (id)initWithUserLocation:(CLLocationCoordinate2D)myuserLocation
{
    self = [super init];
    if (self) {
        // Custom initialization
        _tmpPinViewArray = [[NSMutableArray alloc] initWithCapacity:20];
        _tmpLocationArray= [[NSMutableArray alloc] initWithCapacity:20];
        _clusterAnnotationViews = [[NSMutableArray alloc] initWithCapacity:20];
        _annotationsDisplayed = NO;
        clusterer = nil;
        userLocation = myuserLocation;
        if(!theService) {
            AppMakrSocializeService * ss = [[AppMakrSocializeService alloc]init];
            theService = ss;
            theService.delegate = self;
        }
    }
    return self;
}


- (void)dealloc
{
    self.theService = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.

/*
- (void)loadView
{
    [self addMapView];
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
-(float) MilesToMeters:(float) miles {
    // 1 mile is 1609.344 meters
    // source: http://www.google.com/search?q=1+mile+in+meters
    return 1609.344f * miles;
}
#define REFRESH_DISTANCE 4000
#define SQUARE_MILES        5


- (void)viewDidLoad
{
    DebugLog(@"ActivityMapViewController   %@", self.view);
    [super viewDidLoad];
    [self addMapView];

    CLLocationCoordinate2D centerPoint = userLocation;
    
    mapView.region = MKCoordinateRegionMakeWithDistance(
                                                        centerPoint, 
                                                        [self MilesToMeters:(SQUARE_MILES)],
                                                        [self MilesToMeters:(SQUARE_MILES)]
                                                        );

	[[self mapView] regionThatFits:mapView.region];
    self.mapView.showsUserLocation = YES;
    [self setOperationQueue:[[[NSOperationQueue alloc] init] autorelease]];
    
    NSNotificationCenter * notificationCenter  = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(updateLocation:) name:OBSERVER_DID_LOCATION_UPDATE object:nil];

}


-(void) updateLocation:(NSNotification *)notification{

    AppMakrNativeLocation *updatedLocation = [AppMakrNativeLocation sharedInstance];

    if (mapIsDisplayed){
        
        MKMapPoint pointDispalyedOnMap = MKMapPointForCoordinate(userLocation);
        MKMapPoint updatedPoint = MKMapPointForCoordinate(updatedLocation.lastKnownLocation.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(pointDispalyedOnMap, updatedPoint);
        
        if (distance > REFRESH_DISTANCE){
            userHasMovedEnough = YES;
            [self startRequest];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchActivities:(NSArray *)activities error:(NSError *)error
{
	DebugLog(@"Activity error: %@", [error localizedDescription]);
    self.activitiesArray = activities;
    isRequestInProcess = NO;
    if (userHasMovedEnough){
        [self removeAnnotations];
        userHasMovedEnough = NO;
        _annotationsDisplayed = NO;
    }

    if (self.mapIsDisplayed){
        [self setupAnnotations];
    }
}

-(NSString *) timeString:(NSDate *)date
{
	NSString * formatString = @"%i%@";
	NSInteger timeInterval = (NSInteger) ceil(fabs([date timeIntervalSinceNow]));
	NSInteger daysHoursMinutesOrSeconds = timeInterval/(24*3600);

	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"d"]; 
	}
	
	daysHoursMinutesOrSeconds = timeInterval/3600;
	
	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"h"]; 
	}
	
	daysHoursMinutesOrSeconds = timeInterval/60;
	
	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"m"]; 
	}
	
	return [NSString stringWithFormat:formatString,timeInterval, @"s"];
}

-(UIBarButtonItem*) createLeftNavigationButtonWithCaption: (NSString*) caption{
    UIButton *backButton = [UIButton blackSocializeNavBarBackButtonWithTitle:caption]; 
    [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backLeftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    return backLeftItem;
}

-(void)popViewController{
    [delegate popMyViewControllerAnimated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    AppMakrPinView* pinView = (AppMakrPinView*)view;
    AppMakrClusterAnnotation* annotation = pinView.annotation;
    
    if ([view isKindOfClass:[AppMakrPinView class]]){
        if ([annotation.activities count] > 1){
            
            ActivityViewController * av = [[ActivityViewController alloc]initWithNibName:@"ActivityViewController" bundle:nil displayMap:NO];
            av.activitiesArray = annotation.activities;
            
            UIBarButtonItem * backLeftItem = [self createLeftNavigationButtonWithCaption:@"Activities"];
            av.navigationItem.leftBarButtonItem = backLeftItem;	
            [backLeftItem release];
            
            [delegate pushMyViewController:av animated:YES];
            [av release];
        }
        else{
            Activity * act = [annotation.activities objectAtIndex:0];
            Entry * entry = act.entry;
            
            EntryViewController* descController;
            if (entry)
            {
                descController = [[EntryViewController alloc] initWithEntryID:entry.objectID];
            }
//            else
//                descController = [[EntryViewController alloc] 
//                                  initWithUrlString:act.url  showMediaPlayer:NO];
            
            [delegate pushMyViewController:descController animated:YES];
            [descController release];
        }
    }
}


- (void)transitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (_isMapDisplayed){
        [self setupAnnotations];
    }
}

-(void)refreshPins{
    for (AppMakrPinView* pinView in _clusterAnnotationViews){
        if (pinView.annotation){
            AppMakrClusterAnnotation* clusterAnnotation = pinView.annotation;
            if ([clusterAnnotation.activities count] > 1)
                pinView.pinColor = MKPinAnnotationColorPurple;
            else
                pinView.pinColor = MKPinAnnotationColorGreen;
            
            [pinView setNeedsDisplay];
        }
    }
}

- (void)updateAssetsOnRegion:(NSValue *)value
{
    NSUInteger zoomValue;
	[value getValue:&zoomValue];  
    
    @synchronized(clusterer) {
        if (prevZoomLevelForInvOpr){
            if (zoomValue > prevZoomLevelForInvOpr)
                [clusterer reCalculateForSplitting];
            else
                [clusterer reCalculateForMerging];
        }
        else{
            [clusterer reCalculateForSplitting];
            [clusterer reCalculateForMerging];
        }
        prevZoomLevelForInvOpr = zoomValue;
    }
}

#pragma mark map view delegate callbacks

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

	if ([view.annotation isKindOfClass:[AppMakrClusterAnnotation class]]) {
        if (![view isKindOfClass:[AccessorizedCalloutMapAnnotationView class]]){
            
            if (self.olderCalloutAnnotation == nil)
                self.olderCalloutAnnotation = self.calloutAnnotation;
            
            self.calloutAnnotation = [[CalloutMapAnnotation alloc] initWithLatitude:view.annotation.coordinate.latitude
                                                                       andLongitude:view.annotation.coordinate.longitude];
            
            self.calloutAnnotation.linkedtoAnnotation = (AppMakrClusterAnnotation*)view.annotation;
            [self.mapView addAnnotation:self.calloutAnnotation];
            self.selectedAnnotationView = view;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view isKindOfClass:[AppMakrPinView class]]){
        if (self.olderCalloutAnnotation) {
            [self.mapView removeAnnotation: self.olderCalloutAnnotation];
            self.olderCalloutAnnotation = nil;
        }
        else if (self.calloutAnnotation){
            [self.mapView removeAnnotation: self.calloutAnnotation];
            self.calloutAnnotation = nil;
            self.selectedAnnotationView = nil;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views { 
    MKAnnotationView *aV;
    for (aV in views) {
        
        if ([aV isKindOfClass:[AppMakrPinView class]]){
            AppMakrPinView* pinView = (AppMakrPinView*)aV;
            AppMakrClusterAnnotation* annotation = (AppMakrClusterAnnotation*)pinView.annotation;
            if ((annotation.animateFromFrame.origin.x != 0) || (annotation.animateFromFrame.origin.y != 0)
                || (annotation.animateFromFrame.size.width != 0) || (annotation.animateFromFrame.size.height != 0)){
                CGRect endFrame;    
                endFrame = CGRectMake(pinView.frame.origin.x, pinView.frame.origin.y, pinView.frame.size.width, pinView.frame.size.height);
                pinView.frame = annotation.animateFromFrame;
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.20];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [aV setFrame:endFrame];
                [UIView commitAnimations];
            }
        }
    }
}

#define MAXIMUM_ZOOM 20

- (NSUInteger)zoomLevelForMapRect:(MKMapRect)mRect withMapViewSizeInPixels:(CGSize)viewSizeInPixels
{
    NSUInteger zoomLevel = MAXIMUM_ZOOM; // MAXIMUM_ZOOM is 20 with MapKit
    MKZoomScale zoomScale = mRect.size.width / viewSizeInPixels.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    zoomLevel = (NSUInteger)(MAXIMUM_ZOOM - ceil(zoomExponent));
    return zoomLevel;
}

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
    NSUInteger currentZoom = [self zoomLevelForMapRect:self.mapView.visibleMapRect withMapViewSizeInPixels:self.mapView.frame.size];
    
    if(prevZoomLevel != currentZoom ){
        
        if(self.calloutAnnotation)
            [self.mapView deselectAnnotation:self.selectedAnnotationView.annotation animated:YES];
        
        NSValue *zoomAsValue = [NSValue valueWithBytes:&currentZoom  objCType:@encode(NSUInteger)];
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                          selector:@selector(updateAssetsOnRegion:)
                                                                                            object:zoomAsValue];
        // Cancel any previous operations before we proceed with this one.
        [[self operationQueue] addOperation:invocationOperation];
        
        [invocationOperation release];
        invocationOperation = nil;
        
        prevZoomLevel = currentZoom; 
    }
}

-(UIView*)prepareContentViewForCallout:(AppMakrClusterAnnotation*)cluster{
    
    if (!cluster.activities)
        return nil;
    
    if ([cluster.activities count] > 1){
        
        if (!calloutView){
            calloutView =  [[AppMakrMapCalloutContentView alloc] initWithFrame:CGRectMake(0, 0, 260, 80) imageUrlString:nil placeholderImage:[UIImage imageNamed:@"/socialize_resources/socialize-iphone-group-avatar-icon.png"] subTitleIcon:nil contentType:CALLOUT_ACTIVITY_COUNT] ;
        }
        else
            [calloutView updateCalloutContentType:CALLOUT_ACTIVITY_COUNT];
        calloutView.profileImageView.image = [UIImage imageNamed:@"/socialize_resources/socialize-iphone-group-avatar-icon.png"];
        calloutView.titleLabel.text = [NSString stringWithFormat:@"%d Items",[cluster.activities count]];
        calloutView.subTitleLabel.text = @"";
        calloutView.iconView.image = nil;
        return calloutView;
    }
    else{
        
        Activity* activity = [cluster.activities objectAtIndex:0];
        NSString* profileImageName = nil;
        
        NSString* iconName = nil;
        switch (activity.type) {
            case ACTIVITY_TYPE_LIKE:
                iconName = @"/socialize_resources/socialize-activity-cell-icon-like.png";
                break;
            case ACTIVITY_TYPE_COMMENT:
                iconName = @"/socialize_resources/socialize-activity-cell-icon-comment.png";
                break;
            case ACTIVITY_TYPE_SHARE_TWITTER:
                iconName = @"/socialize_resources/socialize-activity-cell-icon-twitter.png";
                break;
            case ACTIVITY_TYPE_SHARE_FACEBOOK:
                iconName =@"/socialize_resources/socialize-activity-cell-icon-facebook.png";
                break;
            case ACTIVITY_TYPE_SHARE_EMAIL:
                iconName = @"/socialize_resources/socialize-activity-cell-icon-share.png";
                break;
            default:
                break;
        }
        
        profileImageName = activity.userSmallImageURL;
        
        if (!calloutView) {
            
            if (!activity.userImageDownloaded) {
                calloutView = [[AppMakrMapCalloutContentView alloc] initWithFrame:CGRectMake(0, 0, 260, 80) imageUrlString:activity.userSmallImageURL placeholderImage:[UIImage imageNamed:@"/socialize_resources/socialize-activity-userprofile-image.png"]  subTitleIcon:[UIImage imageNamed:iconName ] contentType:CALLOUT_CONTENT];
            }
            else{
                calloutView = [[AppMakrMapCalloutContentView alloc] initWithFrame:CGRectMake(0, 0, 260, 80) imageUrlString:nil placeholderImage:[UIImage imageNamed:@"/socialize_resources/socialize-activity-userprofile-image.png"]  subTitleIcon:[UIImage imageNamed:iconName] contentType:CALLOUT_CONTENT];
            }
        }
        else{
            [calloutView updateCalloutContentType:CALLOUT_CONTENT];
            [calloutView updateProfileImageWithUrlString:profileImageName placeholderImage:[UIImage imageNamed:@"/socialize_resources/socialize-activity-userprofile-image.png"]]; 
        }
        
        NSString * nameAndHourString = [NSString stringWithFormat:@"%@ about %@ ago",activity.username, [self timeString:activity.date]];
        
        calloutView.titleLabel.text = activity.title;
        calloutView.subTitleLabel.text = nameAndHourString;
        calloutView.iconView.image = [UIImage imageNamed:iconName];
        
        return calloutView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
	// try to dequeue an existing pin view first
    if (annotation == aMapView.userLocation)
        return nil;
    
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
    else if([annotation isKindOfClass:[CalloutMapAnnotation class]]) {
        CalloutMapAnnotation* callOutAnnotation = (CalloutMapAnnotation*)annotation;
		CalloutMapAnnotationView *calloutMapAnnotationView = (CalloutMapAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
		if (!calloutMapAnnotationView) {
			calloutMapAnnotationView = [[[AccessorizedCalloutMapAnnotationView alloc] initWithAnnotation:annotation 
                                                                                         reuseIdentifier:@"CalloutAnnotation"] autorelease];
			calloutMapAnnotationView.contentHeight = 78.0f;
			UIImage *asynchronyLogo = [UIImage imageNamed:@"/socialize_resources/profile_placeholder.png"];
			UIImageView *asynchronyLogoView = [[[UIImageView alloc] initWithImage:asynchronyLogo] autorelease];
			asynchronyLogoView.frame = CGRectMake(5, 2, asynchronyLogoView.frame.size.width, asynchronyLogoView.frame.size.height);
		}
        
        [calloutMapAnnotationView adjustMapRegionIfNeeded];
        [calloutMapAnnotationView.contentView addSubview:[self prepareContentViewForCallout:callOutAnnotation.linkedtoAnnotation] ];
		calloutMapAnnotationView.parentAnnotationView = self.selectedAnnotationView;
		calloutMapAnnotationView.mapView = self.mapView;
        calloutMapAnnotationView.canShowCallout = NO;
		return calloutMapAnnotationView;
	}
	else {
		static NSString* entryAnnotationIdentifier = @"clusterAnnotationIdentifier";		
		MKPinAnnotationView* pinView = (MKPinAnnotationView *) [aMapView dequeueReusableAnnotationViewWithIdentifier:entryAnnotationIdentifier];		
        AppMakrPinView* customPinView;
        AppMakrClusterAnnotation * ea;
		if (!pinView)
		{
			// if an existing pin view was not available, create one
			customPinView = [[[AppMakrPinView alloc]
                              initWithAnnotation:annotation reuseIdentifier:entryAnnotationIdentifier] autorelease];
            
            [_clusterAnnotationViews addObject:customPinView];
        }
        else
            customPinView = (AppMakrPinView*)pinView;
        
        ea = (AppMakrClusterAnnotation *)annotation;
        if ([ea totalActivities] > 1){
            UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            myDetailButton.frame = CGRectMake(0, 0, 23, 23);
            myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            customPinView.leftCalloutAccessoryView = myDetailButton;
        }
        customPinView.pinColor = MKPinAnnotationColorGreen;
        if ((ea.animateFromFrame.origin.x != 0) || (ea.animateFromFrame.origin.y != 0)
            || (ea.animateFromFrame.size.width != 0) || (ea.animateFromFrame.size.height != 0)){
            customPinView.animatesDrop = NO;
        }
        else
            customPinView.animatesDrop = YES;
        
        AppMakrClusterAnnotation* prevAnnotation = (AppMakrClusterAnnotation*)customPinView.annotation;
        prevAnnotation.pinView = nil;
        ea.pinView = customPinView;
        
        customPinView.canShowCallout = NO;
        UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(rightCalloutClicked:) forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = rightButton;
        customPinView.annotation = annotation;
        return customPinView;	
    }
    return nil;
}

- (void) rightCalloutClicked:(id)button {
	DebugLog(@"right callout clicked!  adding more to the navigation");	
	// create a new ViewController called DescriptionViewController and push it over the RootViewController
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    //	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    //	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    //	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)refreshActivies {
    
    [self removeAnnotations]; 
    [self startRequest];
}

-(void)startRequest{
    if (!isRequestInProcess){
        isRequestInProcess = YES;
        AppMakrNativeLocation *updatedLocation = [AppMakrNativeLocation sharedInstance];
        userLocation = updatedLocation.lastKnownLocation.coordinate;
        [theService fetchActivitiesForCurrentUserNear:userLocation radius:SQUARE_MILES];
    }
}

-(void)setupAnnotations {
    
    if (!_annotationsDisplayed) {

        if (!clusterer){
            clusterer = [[AppMakrClusterer alloc] initWithMapAndAnnotations:self.mapView];
        }
        
        for(Activity* activity in self.activitiesArray){
            if (activity.myGeoPoint){
                if ((activity.myGeoPoint.lat != 0) && (activity.myGeoPoint.lng != 0))
                    [clusterer addActivity:activity animateFromCluster:nil];
            }
        }
        [self.mapView addAnnotations:[clusterer clusters]];

        if ([activitiesArray count])
            _annotationsDisplayed = YES;
    }
}

- (MKCoordinateRegion)regionFromLocations {
    
    CLLocationCoordinate2D upper = [[_tmpLocationArray objectAtIndex:0] coordinate];
    CLLocationCoordinate2D lower = [[_tmpLocationArray objectAtIndex:0] coordinate];
    
    // FIND LIMITS
    for(CLLocation *eachLocation in _tmpLocationArray) {
        if([eachLocation coordinate].latitude > upper.latitude) upper.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].latitude < lower.latitude) lower.latitude = [eachLocation coordinate].latitude;
        if([eachLocation coordinate].longitude > upper.longitude) upper.longitude = [eachLocation coordinate].longitude;
        if([eachLocation coordinate].longitude < lower.longitude) lower.longitude = [eachLocation coordinate].longitude;
    }
    
    // FIND REGION
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = upper.latitude - lower.latitude;
    locationSpan.longitudeDelta = upper.longitude - lower.longitude;
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (upper.latitude + lower.latitude) / 2;
    locationCenter.longitude = (upper.longitude + lower.longitude) / 2;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    return region;
}

-(void)removeAnnotations{
/*    for(id<MKAnnotation> notation in _tmpPinViewArray){
        [self.mapView removeAnnotation:notation];
    }
    
    [self.mapView removeAnnotations:_tmpPinViewArray];
    [_tmpPinViewArray removeAllObjects]; 
    [_tmpLocationArray removeAllObjects];
 */
    if (clusterer){
        @synchronized(clusterer){
            [self.mapView removeAnnotations:[clusterer clusters]];
            [clusterer removeActivities];
            
            if (self.calloutAnnotation){
                [self.mapView removeAnnotation:self.calloutAnnotation];
                self.calloutAnnotation = nil;
            }

            if (self.olderCalloutAnnotation){
                [self.mapView removeAnnotation:self.olderCalloutAnnotation];
                self.olderCalloutAnnotation = nil;
            }
            _annotationsDisplayed = NO;
        }
    }
}

-(void)addMapView{
    
	MKMapView * aMapView = [[MKMapView alloc] init];
	self.mapView = aMapView;
	[aMapView release];
	
	self.mapView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.mapView.delegate = self;
	[self.view addSubview:mapView];
    
	AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
   	DebugLog(@"placing pin for user here: %f %f", location.lastKnownLocation.coordinate.latitude, location.lastKnownLocation.coordinate.longitude);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
