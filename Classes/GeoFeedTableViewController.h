//
//  GeoFeedViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "FeedTableViewController.h"
#import <MapKit/MapKit.h>

@interface GeoFeedTableViewController : FeedTableViewController<MKReverseGeocoderDelegate> {
	BOOL			hasReceivedLocationNotification;
	BOOL			hasShownLocationServicesMessage;
	NSString		*originalRSSFeedURL;
	MKPlacemark		*currentPlacemark;
}
@property(nonatomic, retain) MKPlacemark * currentPlacemark;

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark;
@end
