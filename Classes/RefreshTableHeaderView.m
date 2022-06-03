//
//  RefreshTableHeaderView.m
//  appbuildr
//
//  Created by Vivian Aranha on 11/24/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "RefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]


@implementation RefreshTableHeaderView

@synthesize isFlipped, currentStatus, placemarkLabel;

- (void)dealloc {
	
	[activityView release];
	[statusLabel release];
	[arrowImage release];
	[lastUpdatedLabel release];
	[placemarkLabel release];
    [super dealloc];

 }

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
		lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, frame.size.width, 20.0f)];
		lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		lastUpdatedLabel.textColor = TEXT_COLOR;
		//lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:lastUpdatedLabel];
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshTableView_LastRefresh"]) {
			lastUpdatedLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"RefreshTableView_LastRefresh"];
		} else {
			[self setCurrentDate];
		}
		
		[lastUpdatedLabel release];
		
		placemarkLabel= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, frame.size.width, 20.0f)];
		placemarkLabel.backgroundColor = [UIColor clearColor];
		placemarkLabel.font = [UIFont systemFontOfSize:12.0f];
		placemarkLabel.textAlignment = UITextAlignmentCenter;
		placemarkLabel.textColor = TEXT_COLOR;

		placemarkLabel.text = @"";
		[self addSubview:placemarkLabel];
		
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, frame.size.width, 20.0f)];
		statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		statusLabel.textColor = TEXT_COLOR;
		//statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		//statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = UITextAlignmentCenter;
		[self setStatus:kPullToReloadStatus];
		[self addSubview:statusLabel];
		[statusLabel release];
		
		arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f)];
		arrowImage.contentMode = UIViewContentModeScaleAspectFit;
		arrowImage.image = [UIImage imageNamed:@"blueArrow.png"];
		[arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		[self addSubview:arrowImage];
		[arrowImage release];
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
		[activityView release];

		isFlipped = NO;
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawPath(context,  kCGPathFillStroke);
	[BORDER_COLOR setStroke];
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - 1);
	CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - 1);
	CGContextStrokePath(context);

	lastUpdatedLabel.frame = CGRectMake(0.0f, self.frame.size.height - 40.0f, self.frame.size.width, 20.0f);
	statusLabel.frame = CGRectMake(0.0f, self.frame.size.height - 58.0f, self.frame.size.width, 20.0f);
	
	placemarkLabel.frame = CGRectMake(0.0f, self.frame.size.height - 22.0f, self.frame.size.width, 20.0f);
	
	arrowImage.frame = CGRectMake(25.0f, self.frame.size.height - 65.0f, 30.0f, 55.0f);
	activityView.frame = CGRectMake(25.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
 
}

- (void)flipImageAnimated:(BOOL)animated{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animated ? .18 : 0.0];
	[arrowImage layer].transform = isFlipped ? CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
	
	isFlipped = !isFlipped;
}

- (void)setCurrentDate {
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setAMSymbol:@"AM"];
	[formatter setPMSymbol:@"PM"];
	[formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
	lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:[NSDate date]]];
	[[NSUserDefaults standardUserDefaults] setObject:lastUpdatedLabel.text forKey:@"RefreshTableView_LastRefresh"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[formatter release];
}

- (void)setStatus:(RefreshStatus)newStatus{
	
	if (newStatus != kNoConnectionStatus && ![NetworkCheck hasInternet]) {
		newStatus = kNoConnectionStatus;
	}
	
	self.currentStatus = newStatus;
	switch (newStatus) {
		case kReleaseToReloadStatus:
			statusLabel.text = @"Release to refresh...";
			break;
		case kPullToReloadStatus:
			statusLabel.text = @"Pull down to refresh...";
			break;
		case kLoadingStatus:
			statusLabel.text = @"Loading...";
			break;
		case kNoConnectionStatus:
			statusLabel.text = @"No Network Connection";
			break;
		default:
			break;
	}
}

- (void)animateActivityView:(BOOL)animate {
	if (animate) {
		[activityView startAnimating];
		arrowImage.hidden = YES;
		[self setStatus:kLoadingStatus];
	} else {
		[activityView stopAnimating];
		arrowImage.hidden = NO;
	}	
}

- (void)toggleActivityView{
	if ([activityView isAnimating]) {
		[activityView stopAnimating];
		arrowImage.hidden = NO;
	} else {
		[activityView startAnimating];
		arrowImage.hidden = YES;
		[self setStatus:kLoadingStatus];
	}	
}

@end