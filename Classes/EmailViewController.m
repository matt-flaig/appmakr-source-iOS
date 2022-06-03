    //
//  EmailViewController.m
//  appbuildr
//
//  Created by William M. Johnson on 7/14/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "EmailViewController.h"
#import "NSData+Base64Additions.h"
#import "GlobalVariables.h"

@implementation EmailViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*-(void)sendMessage
{
	
	NSMutableArray * emailPartsArray = [NSMutableArray arrayWithCapacity:3];
	
	NSString * messageBody = nil;
	messageBody = [self formatString:textView.text];
	
	Location * location = [Location sharedInstance];
	messageBody = [messageBody stringByAppendingFormat:@"\nlat: %f \nlng: %f ", 
				   location.lastKnownLocation.coordinate.latitude, location.lastKnownLocation.coordinate.longitude];
	
	
	
	if (messageBody) 
	{
		NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
								   messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
		
		[emailPartsArray addObject:plainPart];
	}
	if(selectedImage) 
	{
		
		NSData * imageData = [self formatData:UIImageJPEGRepresentation(selectedImage, 1)];
		
		if (imageData) 
		{
		
			NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/png;\r\n\tx-unix-mode=0644;\r\n\tname=\"selected_picture.jpg\"",kSKPSMTPPartContentTypeKey,
								                     
								@"attachment;\r\n\tfilename=\"selected_picture.jpg\"",
								 kSKPSMTPPartContentDispositionKey,
								 [imageData encodeBase64ForData],
								 kSKPSMTPPartMessageKey,@"base64",
								 kSKPSMTPPartContentTransferEncodingKey,nil];
		
			[emailPartsArray addObject:vcfPart]; 
		}
		
								 
								 
	}
	
	if ([emailPartsArray count] > 0) 
	{
		//We should definitely put a wrapper around this message object
		//So that we can give it a better programing interface
		
		NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
		
		NSString * serverName = [defaults objectForKey:@"servername"];
		
		NSNumber * portNumber = [defaults objectForKey:@"portNumber"];
		NSString * username = [defaults objectForKey:@"username"];
		NSString * password = [defaults objectForKey:@"password"];
        NSString * toAddress = [defaults objectForKey:@"toAddress"];
		
		
		SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
		emailMessage.fromEmail = username;
		emailMessage.toEmail = toAddress;
		emailMessage.relayHost = serverName;
		emailMessage.requiresAuth = YES;
		if (portNumber != nil) 
		{
			emailMessage.relayPorts = [NSArray arrayWithObject:portNumber];	
		}
		emailMessage.login = username;
		emailMessage.pass = password;
		emailMessage.subject = @"AppMakr Message";
		emailMessage.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
		
		// Only do this for self-signed certs!
		// emailMessage.validateSSLChain = NO;
		emailMessage.delegate = self;
		
		emailMessage.parts = emailPartsArray;
		
		[emailMessage send];	
	}
	else 
	{
		[self messageWasCanceled:nil];
	}

		
	
}*/


-(void)sendMessage:(NSString *)message withImage:(NSData *)imageData AndLocation:(CLLocation *) currentLocation
{
	NSMutableArray * emailPartsArray = [NSMutableArray arrayWithCapacity:3];
	
	NSString * messageBody = nil;
	messageBody = [NSString stringWithFormat: 
				   @"%@\nDevice ID:%@\nApplication Name:%@\nApplication ID: %@", 
				   message,
				   deviceID,
				   applicationName,
				   applicationID];
	
	if (self.includeLocation) 
	{
		NSString * locationString = 	[NSString stringWithFormat:@"\nlat: %f \nlng: %f \ncompass:%f",
										 currentLocation.coordinate.latitude, 
										 currentLocation.coordinate.longitude, 
										 currentLocation.course]; 
		
		messageBody = [messageBody stringByAppendingString:locationString];
	}
	
	
	if (messageBody) 
	{
		
		messageBody = [self formatString:messageBody];
		
		NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
								   messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
		
		[emailPartsArray addObject:plainPart];
	}
	if(imageData) 
	{
		
		//NSData * imageData = [self formatData:imageData];
		imageData = [self formatData:imageData];
		
		if (imageData) 
		{
			
			NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/png;\r\n\tx-unix-mode=0644;\r\n\tname=\"selected_picture.jpg\"",kSKPSMTPPartContentTypeKey,
									 
									 @"attachment;\r\n\tfilename=\"selected_picture.jpg\"",
									 kSKPSMTPPartContentDispositionKey,
									 [imageData encodeBase64ForData],
									 kSKPSMTPPartMessageKey,@"base64",
									 kSKPSMTPPartContentTransferEncodingKey,nil];
			
			[emailPartsArray addObject:vcfPart]; 
		}
		
		
		
	}
	
	if ([emailPartsArray count] > 0) 
	{
		//We should definitely put a wrapper around this message object
		//So that we can give it a better programing interface
		
		NSDictionary* configs = [GlobalVariables configsForModulePath:self.modulePath];

		NSString * serverName = [GlobalVariables serverName:configs];
		NSNumber * portNumber = [GlobalVariables portNumber:configs];
		NSString * username = [GlobalVariables username:configs];
		NSString * password = [GlobalVariables password:configs];
        NSString * toAddress = [GlobalVariables adress:configs];
		
		
		SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
		emailMessage.fromEmail = username;
		emailMessage.toEmail = toAddress;
		emailMessage.relayHost = serverName;
		emailMessage.requiresAuth = YES;
		if (portNumber != nil) 
		{
			emailMessage.relayPorts = [NSArray arrayWithObject:portNumber];	
		}
		emailMessage.login = username;
		emailMessage.pass = password;
		emailMessage.subject = @"AppMakr Message";
		emailMessage.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
		
		// Only do this for self-signed certs!
		// emailMessage.validateSSLChain = NO;
		emailMessage.delegate = self;
		
		emailMessage.parts = emailPartsArray;
		
		[emailMessage send];	
	}
	else 
	{
		[self messageWasCanceled:nil];
	}
	
	
	
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    [message release];
    
    NSLog(@"delegate - message sent");
	[self messageWasSent:nil];
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    [message release];
    
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
	[self messageDidFail:nil error:error];
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


- (void)dealloc {
    [super dealloc];
}


@end
