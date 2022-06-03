//
//  MFMailComposeViewController+URLExtension.m
//  appbuildr
//
//  Created by Fawad Haider  on 12/1/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "MFMailComposeViewController+URLExtension.h"


@implementation MFMailComposeViewController(URLExtension)
+(MFMailComposeViewController*) composerWithInfoFromUrl:(NSURL*)url  withDelegate:(id<MFMailComposeViewControllerDelegate>)controllerDelegate{

	MFMailComposeViewController *mailer = [[[MFMailComposeViewController alloc] init] autorelease];
	mailer.mailComposeDelegate = controllerDelegate;
	[mailer setToRecipients:[NSArray arrayWithObject:url.resourceSpecifier]];
	
	// copied from http://stackoverflow.com/questions/2225814/nsurl-pull-out-a-single-value-for-a-key-in-a-parameter-string
	/********************************************************/
	NSString * q = [url query];
	NSArray * pairs = [q componentsSeparatedByString:@"&"];
	NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
	for (NSString * pair in pairs) {
		NSArray * bits = [pair componentsSeparatedByString:@"="];
		NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[kvPairs setObject:value forKey:key];
	}
	
	DebugLog(@"subject = %@", [kvPairs objectForKey:@"subject"]);
	DebugLog(@"body = %@", [kvPairs objectForKey:@"body"]);
	/********************************************************/
	
	NSString *body = [kvPairs objectForKey:@"body"];
	NSString *subject = [kvPairs objectForKey:@"subject"];
	[mailer setMessageBody:body isHTML:NO];
	[mailer setSubject:subject];
	return mailer; 
}
@end
