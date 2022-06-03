//
//  CaptionView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 4/28/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CaptionView : UIView {

	UILabel* descriptionLabel;
	UILabel* titleLabel;
}
- (id)initWithFrame:(CGRect)aRect title:(NSString*)aTitle description:(NSString *)aDescription;
@end
