//
//  SocializeStatsView.h
//  appbuildr
//
//  Created by FawadHaider  on 12/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"
typedef enum {
    HorizontalAligned = 1,
	VerticalAligned = 2
} StatsAlignment;


@interface SocializeStatsView : UIView {

	NSString*   viewsCountString;
	NSString*   likesCountString;
	NSString*   commentsCountSting;
	
	BOOL		hasNewComment;
	BOOL		hasbeenLiked;
	BOOL		hasBeenViewed;

	UIFont*		_countStringFont;
	StatsAlignment _alignment;

	BOOL		_drawBackViewShadows;
	
	CGPoint		_viewesDrawPoint;
	CGPoint		_likesDrawPoint;
	CGPoint		_commentsDrawPoint;
}

@property (retain, nonatomic) NSString	*viewsCountString;
@property (retain, nonatomic) NSString	*likesCountString;
@property (retain, nonatomic) NSString	*commentsCountSting;

@property (nonatomic, assign) BOOL	hasNewComment;
@property (nonatomic, assign) BOOL	hasBeenLiked;
@property (nonatomic, assign) BOOL	hasBeenViewed;

- (id)initWithFrame:(CGRect)frame withStatsAlignment:(StatsAlignment)alignment;
@end
