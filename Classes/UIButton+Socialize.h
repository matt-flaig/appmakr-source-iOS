//
//  UIButton+Socialize.h
//  appbuildr
//
//  Created by William M. Johnson on 4/7/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
	AMSOCIALIZE_BUTTON_TYPE_RED,
	AMSOCIALIZE_BUTTON_TYPE_BLUE,
    AMSOCIALIZE_BUTTON_TYPE_BLACK
}AMSocializeButtonType;

@interface UIButton (Socialize)

-(void)configureWithTitle:(NSString *)title type:(AMSocializeButtonType)type;
-(void)configureWithType:(AMSocializeButtonType)type;

+(UIButton *)redSocializeNavBarButton;
+(UIButton *)redSocializeNavBarButtonWithTitle:(NSString *)title;

+(UIButton *)blueSocializeNavBarButton;
+(UIButton *)blueSocializeNavBarButtonWithTitle:(NSString *)title;

+(UIButton *)blackSocializeNavBarButton;
+(UIButton *)blackSocializeNavBarButtonWithTitle:(NSString *)title;

+(UIButton *)blackSocializeNavBarBackButtonWithTitle:(NSString *)title;
@end
