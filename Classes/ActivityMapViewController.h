//
//  ActivityMapViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 4/26/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppMakrClusterer.h"
#import "AppMakrClusterAnnotation.h"

#import "AppMakrSocializeService.h"
#import "MasterController.h"
#import "CalloutMapAnnotation.h"
#import "BasicMapAnnotation.h"
#import "AppMakrMapCalloutContentView.h"
#import "UserAnnotation.h"


@protocol NavigationControllerDelegate 

-(void)pushMyViewController:(UIViewController*)viewController animated:(BOOL)animated;
-(void)popMyViewControllerAnimated:(BOOL)animated;

@end

@interface ActivityMapViewController : MasterController<AppMakrSocializeServiceDelegate, MKMapViewDelegate> {
    
    AppMakrSocializeService			*theService;
	NSArray						*activitiesArray;
    id<NavigationControllerDelegate> delegate;                

    MKMapView                   *mapView;
    BOOL                        _isMapDisplayed;
    BOOL                        _annotationsDisplayed;
    NSMutableArray              *_tmpPinViewArray;
    NSMutableArray              *_clusterAnnotationViews;
    NSMutableArray              *_tmpLocationArray;
    AppMakrClusterer            *clusterer;
    NSOperationQueue            *operationQueue;
    
    CalloutMapAnnotation        *olderCalloutAnnotation;
    CalloutMapAnnotation        *calloutAnnotation;
	MKAnnotationView            *selectedAnnotationView;
    
    NSUInteger                  prevZoomLevel;
    NSUInteger                  prevZoomLevelForInvOpr;
    
	NSMutableDictionary         *userImageDictionary;
    AppMakrMapCalloutContentView      *calloutView;
    UIActivityIndicatorView			  *activitySpinner;
    
    BOOL                               mapIsDisplayed;
    BOOL                               userHasMovedEnough;
    BOOL                               isRequestInProcess;
    CLLocationCoordinate2D             userLocation;
}

@property (assign)   BOOL     mapIsDisplayed;
@property (assign, nonatomic)   CLLocationCoordinate2D     userLocation;
@property (nonatomic, retain) MKMapView*  mapView;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (nonatomic, retain) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, retain) CalloutMapAnnotation *calloutAnnotation;
@property (nonatomic, retain) CalloutMapAnnotation *olderCalloutAnnotation;
@property (nonatomic, retain) AppMakrSocializeService *theService;
@property (nonatomic, retain) NSArray		   *activitiesArray;

@property (assign) id<NavigationControllerDelegate> delegate;

-(void)setupAnnotations;
-(void)refreshActivies ;
-(id)initWithUserLocation:(CLLocationCoordinate2D)myuserLocation;

@end
