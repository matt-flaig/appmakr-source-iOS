//
//  FeedItemMainCellView.h
//  appbuildr
//
//  Created by Fawad Haider  on 12/15/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VarietyTableCellScrollView.h"
//#import "TISwipeableTableView.h"
#import "Entry.h"

@interface FeedItemMainCellView : UIView {

	NSString*	headlineString;
	NSString*	summaryString;
	
	float		headlineLabelHeight;
	float		summaryLabelHeight;
	
	float		leftMargin;
	float		editingMargin;
	float		summaryTopMargin;
	float		thumbnailTargetWidth;
	
	CGSize		headlineSize;
	CGRect		_headlineFrame;
	CGRect		_summaryFrame;

	BOOL		_isEditing;
	BOOL		_isHeadlineHidden;
	BOOL		paintBackground;
	BOOL		highlighted;
	
	UIFont		*_dateFont;
	UIFont		*_summaryFont;
	UIFont		*_headlineFont;
    
    UIColor     *_summaryColor;
    UIColor     *_headlineColor;
	
    BOOL        isLiked;
    BOOL        hasNewComment;
    UIImage     *thumbnailImage;
    NSString    *updatedDate;
}


@property (nonatomic, assign) BOOL		highlighted;
//@property (nonatomic, retain) Entry		*entry;
@property (nonatomic, retain) NSString	*summaryString;
@property (nonatomic, retain) NSString	*headlineString;
@property (nonatomic, retain) NSString	*updatedDate;

- (id)initWithFrame:(CGRect)frame titleColor:(UIColor *)titleColor descColor:(UIColor *)descColor;

- (void)setupViewWithEntry:(Entry *)cellEntry withIndention:(BOOL)isEditing;
- (void)setSelected:(BOOL)selected;
- (void)prepareForReuse;

@end
