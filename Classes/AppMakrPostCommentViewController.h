//
//  AppMakrPostCommentViewController.h
//  appbuildr
//
//  Created by William M. Johnson on 4/5/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MasterController.h"



@class AppMakrCommentMapView;

@protocol AppMakrPostCommentViewControllerDelegate;

@interface AppMakrPostCommentViewController : MasterController <UITextViewDelegate, MKMapViewDelegate, MKReverseGeocoderDelegate >
{

   @private 
        UITextView * commentTextView;
        UILabel * locationText;
        UIButton * doNotShareLocationButton;
        UIButton * activateLocationButton;
        AppMakrCommentMapView * mapOfUserLocation;
    
        BOOL shareLocation;
        BOOL keyboardIsVisible;
    
        NSString * userLocationText;
        id<AppMakrPostCommentViewControllerDelegate> delegate; 
}
@property(nonatomic, retain) IBOutlet UITextView * commentTextView;
@property(nonatomic, retain) IBOutlet UILabel * locationText;
@property(nonatomic, retain) IBOutlet UIButton * doNotShareLocationButton;
@property(nonatomic, retain) IBOutlet UIButton * activateLocationButton;
@property(nonatomic, retain) IBOutlet AppMakrCommentMapView * mapOfUserLocation;
@property(nonatomic, assign) id<AppMakrPostCommentViewControllerDelegate> delegate; 

-(IBAction)activateLocationButtonPressed:(id)sender;
-(IBAction)doNotShareLocationButtonPressed:(id)sender;
@end


@protocol AppMakrPostCommentViewControllerDelegate 

-(void)postCommentController:(AppMakrPostCommentViewController*) controller sendComment:(NSString*)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)shareLocation;

    -(void)postCommentControllerCancell:(AppMakrPostCommentViewController*) controller; 
@end
