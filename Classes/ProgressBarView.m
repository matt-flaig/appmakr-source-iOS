//
//  ProgressBarView.m
//  appbuildr
//
//  Created by Brian Schwartz on 1/4/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ProgressBarView.h"


@implementation ProgressBarView

@synthesize dataLabel;
@synthesize progressView;
@synthesize feedStarted;


- (id)initWithFrame:(CGRect)frame {
    
	if ((self = [super initWithFrame:frame])) {
        
		feedStarted = NO;
		
		self.hidden = YES;
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		UILabel *aDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, self.frame.size.height/2 - 20, self.frame.size.width/2 + 10, 20)];
		[aDataLabel setText:@"Downloading..."];
		[aDataLabel setTextAlignment:UITextAlignmentCenter];
		[aDataLabel setFont:[UIFont boldSystemFontOfSize:15]];
		[aDataLabel setTextColor:[UIColor whiteColor]];
		[aDataLabel setBackgroundColor:[UIColor clearColor]];
		dataLabel = aDataLabel;
		
		UIProgressView *aProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(50, self.frame.size.height/2 + 5, self.frame.size.width/2 + 60, 20)];
		[aProgressView setProgressViewStyle:UIProgressViewStyleDefault];
		progressView = aProgressView;
		
		UIToolbar *aClearView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[aClearView setTintColor:[UIColor darkTextColor]];
		[aClearView setAlpha:0.80];
		[aClearView setTranslucent:YES];
		clearView = aClearView;

		[self addSubview:clearView];
		[self addSubview:dataLabel];
		[self addSubview:progressView];
		
		[aDataLabel release];
		[aProgressView release];
		[aClearView release];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || 
	   [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
		self.dataLabel.frame = CGRectMake(115, self.frame.size.height/2 - 20, self.frame.size.width/2 + 10, 20);
		self.progressView.frame = CGRectMake(90, self.frame.size.height/2 + 5, self.frame.size.width/2 + 60, 20);
		clearView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	} else {
		self.dataLabel.frame = CGRectMake(75, self.frame.size.height/2 - 20, self.frame.size.width/2 + 10, 20);
		self.progressView.frame = CGRectMake(50, self.frame.size.height/2 + 5, self.frame.size.width/2 + 60, 20);
		clearView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	}
	
	[[UIColor blackColor] setStroke];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 2);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0, 1); 
	CGContextAddLineToPoint(context, self.frame.size.width, 1);
	CGContextMoveToPoint(context, 0, self.frame.size.height+1); 
	CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height+1);
	CGContextClosePath (context);
	CGContextDrawPath(context, kCGPathFillStroke);
	UIGraphicsEndImageContext();
}


- (void)dealloc {
	[clearView release];
	[dataLabel release];
	[progressView release];
    [super dealloc];
}


@end
