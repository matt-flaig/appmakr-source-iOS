//
//  GeoFeedViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "GeoFeedTableViewController.h"
#import "FeedParser.h"
#import "EntryViewController.h"
#import "EntryMapViewController.h"
#import "Entry.h"
#import "AppMakrNativeLocation.h"
#import "ModuleFactory.h"

@interface GeoFeedTableViewController()
    @property(nonatomic, retain) NSString *originalRSSFeedURL;
@end


@implementation GeoFeedTableViewController
@synthesize currentPlacemark;
@synthesize originalRSSFeedURL;

-(void) dealloc {
	[originalRSSFeedURL release];
	[super dealloc];
}

- (id)initWithFeed:(NSString* )feedUrl title:(NSString *)title {
	if( (self = [super initWithFeed:feedUrl title:title]) ) {
		hasReceivedLocationNotification = NO;
		hasShownLocationServicesMessage = NO;
        self.originalRSSFeedURL = feedUrl;
		NSNotificationCenter * notificationCenter  = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(updateLocation:) name:OBSERVER_DID_LOCATION_UPDATE object:nil];
	}
	return self;
}

-(void)showAllGeoEntriesButtonPressed:(id)sender
{
	AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
	EntryMapViewController * entryMapViewController = [[EntryMapViewController alloc] initWithFeedID:feed.objectID userLocation:location.lastKnownLocation];
	[self.navigationController pushViewController:entryMapViewController animated:YES];
	[entryMapViewController release];
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	UIBarButtonItem * allButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"All", @"") style:UIBarButtonItemStyleDone target:self action:@selector(showAllGeoEntriesButtonPressed:)];
	self.navigationItem.rightBarButtonItem = allButtonItem;
	[allButtonItem release];
	
}

#pragma mark view controller callbacks 
-(void)viewWillAppear:(BOOL)animated {
	AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
	if( ![location islocationServicesEnabled] ) {
		[self resetRefreshHeader];
		[self hideProgressBar];
		NSString *noLocationServices = 
		[[NSString alloc] initWithFormat: @"Location Services are required for this tab to work.  Please go into your settings and turn location services on."]; 
		UIAlertView *uiAlert = [[UIAlertView alloc]
								initWithTitle:@"location services are required" message:noLocationServices delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[uiAlert show]; 
		[uiAlert release];
		[noLocationServices release];
		hasShownLocationServicesMessage = YES;
	} else {
		[super viewWillAppear:animated];
	}
}

- (void)refreshEntries {

	if ([NetworkCheck hasInternet] && hasReceivedLocationNotification) {
		AppMakrNativeLocation * location = [AppMakrNativeLocation sharedInstance];
              
        if( [self.originalRSSFeedURL rangeOfString:@"?"].location == NSNotFound )
        {
            self.rssFeedUrl = [NSString stringWithFormat:@"%@?&lat=%f&lng=%f", 	
                               self.originalRSSFeedURL, location.lastKnownLocation.coordinate.latitude, location.lastKnownLocation.coordinate.longitude];
        }
        else
        {
            self.rssFeedUrl = [NSString stringWithFormat:@"%@&lat=%f&lng=%f", 	
                              self.originalRSSFeedURL, location.lastKnownLocation.coordinate.latitude, location.lastKnownLocation.coordinate.longitude];
        }
        
		[super refreshEntries];
		MKReverseGeocoder * reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate: location.lastKnownLocation.coordinate];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];		
		//isWaitingForLocationBeforeRefresh = NO;
	} 
	
	if ([NetworkCheck hasInternet] && !hasReceivedLocationNotification) {
		progressBarView.progressView.progress = 0.0;
		progressBarView.alpha = 1.0;
		progressBarView.hidden = NO;
		progressBarView.dataLabel.text = @"Waiting For Location Update...";	
	}	
}

-(void) updateLocation:(NSNotification *)notification{
	if( !hasReceivedLocationNotification ) {
		hasReceivedLocationNotification = YES;
		[self refreshEntries];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	DebugLog(@"reverse geocoding did fail error");
	[geocoder autorelease];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	DebugLog(@"reverse geocoding did finish");
	self.currentPlacemark = placemark;
	NSString * placemarkString = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
	refreshHeaderView.placemarkLabel.text = placemarkString;
	[geocoder autorelease];	
}

#pragma mark table delegate functions
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	currentRow = [indexPath indexAtPosition: [indexPath length] - 1]; 

	Entry * entry = (Entry *)[[feed entriesInOriginalOrder] objectAtIndex:currentRow];
	if( entry.geoPoint ) {
		EntryViewController *entryViewController = [[EntryViewController alloc] initWithEntryID:entry.objectID];
		//EntryViewController *entryViewController = [[EntryViewController alloc] initWithFeedID:entry.feed.objectID storyIndex:currentRow showMediaPlayer:NO];
		[self.navigationController pushViewController:entryViewController animated:YES];
		[entryViewController release];
	} else {
		//if it has no geopoint then default to viewing the story.
		[super tableView:aTableView didSelectRowAtIndexPath:indexPath];
	}
}

- (BOOL) wasConfigurationChanged:(NSDictionary*) configs
{
    DebugLog(@"%@", self.originalRSSFeedURL);
    DebugLog(@"%@", [ModuleFactory feedUrl:configs]);
    return !([self.originalRSSFeedURL isEqualToString:[ModuleFactory feedUrl:configs]] && [self.feedKey isEqualToString:[ModuleFactory tabTitle:configs]]);
}

- (void)applyFeedUrl:(NSString *)feedUrl title:(NSString *)title
{
    [super applyFeedUrl: feedUrl title: title];
    self.originalRSSFeedURL = feedUrl;
}
@end
