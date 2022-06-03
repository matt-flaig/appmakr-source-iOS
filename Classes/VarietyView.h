//
//  VarietyView.h
//  appbuildr
//
//  Created by Brian Schwartz on 12/11/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "Entry.h"


@interface VarietyView : NSObject 
{
	Entry	*entry;
	UIImage *buttonGradientImg;
	UIColor *cellHeadlineColor;
	UIColor *cellSummaryColor;
	BOOL	paintBackground;
	BOOL	highlighted;
	BOOL	isEditing;
	CGRect	frame;
}
@property(nonatomic, assign) CGRect frame;

@property(nonatomic, retain) Entry *entry;
@property(nonatomic, retain) UIColor *cellHeadlineColor;
@property(nonatomic, retain) UIColor *cellSummaryColor;
@property(nonatomic) BOOL paintBackground;
@property(nonatomic) BOOL isEditing;
@property(nonatomic, getter = isHighlighted) BOOL highlighted;
- (void)draw:(CGRect)rect ;

@end
