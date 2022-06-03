//
//  PhotoImageView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 4/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"
#import "CaptionView.h"

@interface PhotoDetailView : UIView {

	Entry			*entry;
	CaptionView		*captionView;
	id				delegate;
	UIImageView		*photoImageView;
	UIActivityIndicatorView * activityView;
	UILabel			*imageStatusLabel;
	BOOL			isCaptionVisble;
	BOOL			fullSizedImageDownloaded;
}

@property(nonatomic,retain)	   UIImageView *photoImageView;
@property(nonatomic,readonly)  UILabel	   *imageStatusLabel;
@property(nonatomic,readonly)  Entry	   *entry;
@property(nonatomic,readonly)  UIActivityIndicatorView * activityView;
@property(nonatomic) BOOL fullSizedImageDownloaded;

-(id)initWithFrame:(CGRect)aRect entry:(Entry *)aEntry tag:(int)aTag delegate:(id)aDelegate;
-(void)toggleCaptionView;
-(void)showCaptionView;
-(void)hideCaptionView;

@end
