//
//  AnalyticsTests.m
//  appbuildr
//
//  Created by Isaac Mosquera on 5/18/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AnalyticsTests.h"
#import "AppMakrAnalytics.h"
#import "GlobalVariables.h"
#import "AppMakrURLDownload.h"

@implementation AnalyticsTests
- (void) testAppDownload {
	NSString * urlToTest = [AppMakrAnalytics logApplicationDownload];	
		
	NSURL *theURL = [NSURL URLWithString:urlToTest];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest	requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0f];
	NSURLResponse *theResponse;
	NSError *theError;
	[NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)theResponse;
	STAssertNil(theError, @"Error when sending request to %@ with error: %@", urlToTest, [theError localizedDescription]);

	AppMakrAnalytics * appmakrAnalytics = [[AppMakrAnalytics alloc] init];
	AppMakrURLDownload * urlDownload = [[AppMakrURLDownload alloc] init];
	BOOL didTrack = [appmakrAnalytics applicationDownloadData:[@"OK" dataUsingEncoding:NSASCIIStringEncoding] urldownload:urlDownload tag:nil];
	
	STAssertTrue(didTrack, @"appmakr tracker failed to persist the data");

	STAssertEquals(httpResponse.statusCode, 200, @"the response from the server is not 200 when doing app download test, response is %i", httpResponse.statusCode);

	STAssertTrue([AppMakrAnalytics hasApplicationDownloadBeenTracked] , @"Could not verify that the app download tracker worked correctly %@", urlToTest);	

}
@end
