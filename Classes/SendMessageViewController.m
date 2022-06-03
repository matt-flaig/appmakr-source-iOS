//
//  SendMessage.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SendMessageViewController.h"
#import "UIViewRounded.h"
#import "GlobalVariables.h"
#import "SendingMessageView.h"
#import "ASIFormDataRequest.h"
#import "ModuleFactory.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_TEXT @"Tap here to enter a message"

@implementation SendMessageViewController

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)sendMessage:(NSString *)message withImage:(NSData *)imageData AndLocation:(CLLocation *) currentLocation
{
	NSDictionary* configs = [GlobalVariables configsForModulePath:self.modulePath];
    NSString* urlStr = [ModuleFactory feedUrl: configs];
	NSURL* url = [NSURL URLWithString:urlStr];
	DebugLog(@"url is %@", url);
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.delegate = self;
	
	[request setPostValue:[self formatString:deviceID] forKey:@"device_id"];
	[request setPostValue:[self formatString:applicationName] forKey:@"application_name"];
	[request setPostValue:[self formatString:applicationID] forKey:@"application_id"];
    
	if (self.includeLocation) 
	{
		NSString* lat = [NSString stringWithFormat:@"%f",  currentLocation.coordinate.latitude];
		NSString* lng = [NSString stringWithFormat:@"%f",  currentLocation.coordinate.longitude];
		NSString* compass = [NSString stringWithFormat:@"%f", currentLocation.course];
		[request setPostValue:[self formatString:lat] forKey:@"lat"];
		[request setPostValue:[self formatString:lng] forKey:@"lng"];
		[request setPostValue:[self formatString:compass] forKey:@"compass"];
	}
	
	
	[request setPostValue:[self formatString:message] forKey:@"message"];
	
	if(imageData) 
	{
		[request setData:[self formatData:imageData] withFileName:@"selected_picture.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
	}
	[request startAsynchronous];
	DebugLog(@"submitting request for send message");
}

#pragma mark ASI delegate calls
- (void)requestFinishedWithStatusCode:(int)statusCode {
    //only 200, 201 and 202 will be accepted as they reflect valid responses
    //200: The item requested of the server is available (keep in mind, available, not accepted or completed).
    //201: A new address has been created through the use of form posting, perl, cgi, etc.
    //202: The request has been accepted (keep in mind that the request has been accepted, not completed).
	if (statusCode == 200 || statusCode == 201 || statusCode == 202) {
        [self messageWasSent:nil];
    }
    else {
        [self messageWasNotSent:nil];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	[self requestFinishedWithStatusCode:request.responseStatusCode];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	[self messageDidFail:nil error:error];
}

@end
