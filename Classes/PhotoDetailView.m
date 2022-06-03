//
//  PhotoImageView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 4/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "PhotoDetailView.h"
#import "RegexKitLite.h"


@implementation PhotoDetailView
@synthesize photoImageView;
@synthesize entry;
@synthesize activityView;
@synthesize imageStatusLabel;
@synthesize fullSizedImageDownloaded;

int HEADER_SIZE = 0	;
int CAPTION_VIEW_HEIGHT_POTRAIT = 125;
int CAPTION_VIEW_HEIGHT_LANDSCAPE = 125;
- (void)dealloc {
	[entry release];
	[captionView release];
	[photoImageView release];
	[activityView release];
	[imageStatusLabel release];
	[super dealloc];
}

-(id)initWithFrame:(CGRect)aRect entry:(Entry *)aEntry tag:(int)aTag delegate:(id)aDelegate {
	if ((self = [super initWithFrame:aRect]) ) {
		entry = [aEntry retain];
		delegate = aDelegate;
		isCaptionVisble = YES;
		self.tag = aTag;
		
		photoImageView = [[UIImageView alloc] init];
		photoImageView.frame = CGRectMake(0,0, aRect.size.width, aRect.size.height);
		photoImageView.userInteractionEnabled = YES;
		photoImageView.autoresizesSubviews = YES;
		photoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoImageView.contentMode = UIViewContentModeScaleAspectFit;		
		
		
		[self addSubview:photoImageView];
		
		
		CGRect captionFrame = CGRectMake(0, aRect.size.height - CAPTION_VIEW_HEIGHT_POTRAIT, 320, CAPTION_VIEW_HEIGHT_POTRAIT);
		entry.mediaSummary = [entry.mediaSummary stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@""];
		captionView = [[CaptionView alloc] initWithFrame:captionFrame title:entry.title description:entry.mediaSummary];
		captionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self addSubview:captionView];
		
		float activityViewWidth = 20.0;
		CGRect activityFrame = CGRectMake(320/2-activityViewWidth, 480/2-activityViewWidth, activityViewWidth, activityViewWidth);
		activityView = [[UIActivityIndicatorView alloc] initWithFrame:activityFrame];
		[self addSubview:activityView];
		
		float labelHeight = 50;
		float labelWidth = 300;
		
		imageStatusLabel = [[UILabel alloc]init];
		imageStatusLabel.frame = CGRectMake((320 - labelWidth)/2, (480 - labelHeight)/2,labelWidth, labelHeight);
		imageStatusLabel.backgroundColor = [UIColor clearColor];
		imageStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		imageStatusLabel.textColor = [UIColor whiteColor];
		imageStatusLabel.text = @"";
		
		[self addSubview:imageStatusLabel];
		
		UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
		imageButton.frame = CGRectMake(0, 0, aRect.size.width, aRect.size.height);
		imageButton.tag = aTag;
		imageButton.backgroundColor = [UIColor clearColor];		
		[imageButton addTarget:delegate action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];		
		[self addSubview:imageButton];
		
		
		
		
		
		
	}
	return self;
}

-(void)layoutSubviews {
	float captionViewHeight = ceil( self.frame.size.height * 0.25 );
	
	
	captionView.frame = CGRectMake( captionView.frame.origin.x, self.frame.size.height - captionViewHeight,
								   captionView.frame.size.width, captionViewHeight); 
	
}
-(void)showCaptionView {
	if(!isCaptionVisble) { //this makes sure the view isn't shown twice and gets misplaced
		float newHeight = self.frame.size.height - captionView.frame.size.height;
		[UIView beginAnimations:@"showCaptionView" context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationBeginsFromCurrentState:YES];
		captionView.frame = CGRectMake(0, newHeight, captionView.frame.size.width,captionView.frame.size.height);
		[UIView commitAnimations];	
		isCaptionVisble = YES;
	}
}

-(void)hideCaptionView {
	if (isCaptionVisble) { //this makes sure the view isn't hidden twice and gets misplaced
		float newHeight = captionView.frame.origin.y + captionView.frame.size.height;		
		[UIView beginAnimations:@"hideCaptionView" context:nil];
		[UIView setAnimationDuration:1];
		[UIView setAnimationBeginsFromCurrentState:YES];
		captionView.frame = CGRectMake(0, newHeight, captionView.frame.size.width,captionView.frame.size.height);
		[UIView commitAnimations];
		isCaptionVisble = NO;
	}
}

-(void)toggleCaptionView {
	if (isCaptionVisble) {
		[self hideCaptionView];
	} else {
		[self showCaptionView];
	}
}

@end
