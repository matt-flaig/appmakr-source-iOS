//
//  TiledImageView.h
//  appbuildr
//
//  Created by Fawad Haider  on 5/18/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TiledImageView : UIView {
    
@private
    UIImage *image_;
}

@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame andImageString:(NSString*)imageString;
@end
