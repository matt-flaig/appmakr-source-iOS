//
//  AppMakrSocializeActionView.h
//  appbuildr
//
//  Created by Fawad Haider  on 12/9/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@protocol AppMakrSocializeActionViewDelegate <NSObject>

-(void)commentButtonTouched:(Entry*)entry;
-(void)likeButtonTouched:(Entry*)entry;
-(void)shareButtonTouched:(Entry*)entry;

@end




@interface AppMakrSocializeActionView : UIView {
	
	UIButton*	commentsBacSocializeActionViewkgroundButton;
	UIButton*	ifViewedBackgroundButton;
	UIButton*	likesBackgroundButton;
	
	UIButton*	commentButton;
	UIButton*	likeButton;
	UIButton*	shareButton;
	UIButton*	viewCounter;
	
	UIFont*		_buttonLabelFont;
	UIColor*	_shadowColor;
	
	BOOL		_drawBackViewShadows;
	BOOL		_observersAdded;
	BOOL		_hasNewComment;
	UIImageView* newCommentMarker;
	UIActivityIndicatorView*  _activityIndicator;
	
	Entry					 *entry;
	id<AppMakrSocializeActionViewDelegate>   socializeDelegate;
}

@property (retain, nonatomic) UIButton	*likeButton;
@property (retain, nonatomic) UIButton	*commentButton;
@property (retain, nonatomic) UIButton	*shareButton;

@property (nonatomic, retain) Entry		*entry;

- (void)setSocializeDelegate:(id)delegate;
- (id)initWithFrame:(CGRect)frame andActionDelegate:(id<AppMakrSocializeActionViewDelegate>)mydelegate andEntry:(Entry*)myentry;
-(void)errorLoadingStats;
-(void)removeObserversForEntry:(Entry*)myentry;

@end