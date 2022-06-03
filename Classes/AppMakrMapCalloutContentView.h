//
//  AppMakrMapCalloutContentView.h
//  appbuildr
//
//  Created by Fawad Haider  on 4/20/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCImageView.h"


typedef enum 
{
	CALLOUT_CONTENT =1,
	CALLOUT_ACTIVITY_COUNT,
} CalloutContentType;



@interface AppMakrMapCalloutContentView : UIView {
    TCImageView         *profileImageView;
    UILabel             *titleLabel;
    UILabel             *subTitleLabel;
    UIImageView         *iconView;
    CalloutContentType  contentType;
    UIView              *shadowView;
}

@property (nonatomic, retain) UILabel     *titleLabel;
@property (nonatomic, retain) UILabel     *subTitleLabel;
@property (nonatomic, retain) TCImageView *profileImageView;
@property (nonatomic, retain) UIImageView *iconView;

- (id)initWithFrame:(CGRect)frame imageUrlString:(NSString *)imageUrlString placeholderImage:(UIImage *)placeholderImage subTitleIcon:(UIImage*)subTitleIcon contentType:(CalloutContentType) contentType;

-(void)updateProfileImageWithUrlString:(NSString *)imageUrlString placeholderImage:(UIImage *)placeholderImage;
-(void)updateCalloutContentType:(CalloutContentType) mycontentType;
@end
