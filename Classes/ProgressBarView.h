//
//  ProgressBarView.h
//  appbuildr
//
//  Created by Brian Schwartz on 1/4/10.
//  Copyright 2010 pointabout. All rights reserved.
//


@interface ProgressBarView : UIView 
{
	UILabel *dataLabel;
	UIProgressView *progressView;
	UIToolbar *clearView;
	bool feedStarted;
}

@property(nonatomic, retain) UILabel *dataLabel;
@property(nonatomic, retain) UIProgressView *progressView;
@property(assign) bool feedStarted;

@end
