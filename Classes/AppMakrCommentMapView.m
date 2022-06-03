//
//  AppMakrCommentMapView.m
//  appbuildr
//
//  Created by Sergey Popenko on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrCommentMapView.h"
#import "UIView+RoundedCorner.h"
#import <QuartzCore/QuartzCore.h>

@interface AppMakrGeoLocationMarker : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;   
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation AppMakrGeoLocationMarker
    @synthesize coordinate;
@end

@implementation AppMakrCommentMapView

-(void) configurate
{
    self.layer.cornerRadius = 9.0f;
    self.layer.masksToBounds = YES;
        
    UIView* shadowView = [[UIView alloc] init];
    shadowView.layer.cornerRadius = 9.0;
    shadowView.layer.shadowColor = [UIColor colorWithRed:48/ 255.f green:57/ 255.f blue:64/ 255.f alpha:1.0].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadowView.layer.shadowOpacity = 0.9f;
    shadowView.layer.shadowRadius = 9.0f;
    
    [self.superview addSubview:shadowView];
    [self removeFromSuperview];
    [shadowView addSubview:self];    
    [shadowView release];
}

-(id)init{
    if ((self = [super init])){
        return self;
    }  
    return nil;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder])){
        return self;
    }
    return nil;
}


-(void) setFitLocation: (CLLocationCoordinate2D) location withSpan: (MKCoordinateSpan) span
{
    MKCoordinateRegion region;
    region.span = span;
    region.center = location;
    
    [self setRegion:[self regionThatFits:region] animated:NO];
}

-(void) setAnnotationOnPoint: (CLLocationCoordinate2D) centerPoint
{
    AppMakrGeoLocationMarker* annotation = [[AppMakrGeoLocationMarker alloc] init];
    annotation.coordinate = centerPoint;
    
    [self addAnnotation: annotation];
    [annotation release];
}

-(void)layoutSubviews
{
    
 //   [self setRoundedCornerOnHierarchy:5];
}
@end
