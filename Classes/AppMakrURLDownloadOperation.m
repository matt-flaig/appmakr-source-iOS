//
//  AppMakrURLDownloadOperation.m
//  appbuildr
//
//  Created by Isaac Mosquera on 6/8/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrURLDownloadOperation.h"


@implementation AppMakrURLDownloadOperation
@synthesize urlConnection;

-(void)dealloc{
	self.urlConnection = nil;
	[super dealloc];
}

-(void) cancel {
	if(self.urlConnection) {
		[self.urlConnection cancel];
	}
	[super cancel];
}
@end
