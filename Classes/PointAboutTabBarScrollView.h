//
//  PATabBarScrollView.h
//  Kaplan
//
//  Created by William M. Johnson on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointAboutTabBarScrollView : UIView {
	
@private
	UIScrollView * tabBarScrollView;
	UIView * contentView;
	bool displayTop;
}

@property (nonatomic, readonly) UIScrollView * tabBarScrollView;
@property (nonatomic, readonly) UIView * contentView;
@property (nonatomic, assign) bool displayTop;
@end
