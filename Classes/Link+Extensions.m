//
//  Link+Extensions.m
//  appbuildr
//
//  Created by William Johnson on 10/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Link+Extensions.h"
#import "LinkUtilities.h"


@implementation Link(Extensions) 



-(NSString *)getHrefExtension 
{
	return [LinkUtilities getHrefExtension:self.href];
}

- (BOOL) hasAudio 
{
	return (self.type && [self.type rangeOfString:@"audio"].location != NSNotFound );
}

- (BOOL) hasImage 
{
	return (self.type && [self.type rangeOfString:@"image"].location != NSNotFound );
}

- (BOOL) hasVideo 
{
	if( self.type && [self.type rangeOfString:@"video"].location != NSNotFound ) {
		return YES;
	}
	return [LinkUtilities hasVideo:self.href];
}

- (BOOL) hasMedia 
{
	return ( [self hasImage] || [self hasVideo] || [self hasAudio] );
}

- (BOOL) hasHttpLiveStreaming 
{
	if( self.type ) {
		NSRange m3u8Range = [[self.href lowercaseString] rangeOfString:@"m3u8"];
		DebugLog(@"the link to test: %@", self.href);
		if( m3u8Range.location != NSNotFound ) {
			DebugLog(@"returning YES for httplivestreaming");
			return YES;
		}
	}
	DebugLog(@"returning NO for httplivestreaming");
	return NO;
}

@end
