//
//  CustomAcitivityView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 7/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

@interface CustomActivityView : UIView {
	
	UIActivityIndicatorView * indicatorView;
	UILabel * labelView;
}
- (id)initWithTitle:(NSString *)title;
@end