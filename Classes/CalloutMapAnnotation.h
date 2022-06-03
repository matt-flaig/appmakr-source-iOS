#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AppMakrClusterAnnotation.h"


@interface CalloutMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
    
    AppMakrClusterAnnotation   *linkedtoAnnotation;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@property (nonatomic, assign) AppMakrClusterAnnotation  *linkedtoAnnotation;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;

//- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
