//
//  TabBarIconView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TabBarIconButton : UIButton {

	UILabel * titleLabel;
	UIImageView *iconImageView; 
}
- (id)initWithTabBarItem:(UITabBarItem *)tabBarItem;
@property (retain, nonatomic) NSString *title;
@end
