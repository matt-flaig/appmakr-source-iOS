//
//  RefreshTableHeaderView.h
//  appbuildr
//
//  Created by Vivian Aranha on 11/24/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkCheck.h"

typedef enum {
	kReleaseToReloadStatus = 0,
	kPullToReloadStatus = 1,
	kLoadingStatus = 2,
	kNoConnectionStatus = 3
} RefreshStatus;

@interface RefreshTableHeaderView : UIView {

	UILabel					*lastUpdatedLabel;
	UILabel					*statusLabel;
	UILabel					*placemarkLabel;
	UIImageView				*arrowImage;
	UIActivityIndicatorView *activityView;
	RefreshStatus			currentStatus;
	BOOL					isFlipped;
}
@property BOOL isFlipped;
@property(nonatomic)RefreshStatus currentStatus;
@property(nonatomic, readonly) UILabel * placemarkLabel; 

- (void)flipImageAnimated:(BOOL)animated;
- (void)setCurrentDate;
- (void)toggleActivityView;
- (void)animateActivityView:(BOOL)animate;
- (void)setStatus:(RefreshStatus)newStatus;

@end

