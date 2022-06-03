//
//  AppMakrUINavigationBarBackground.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UINavigationBar(UINavigationBarCategory) 
- (void)setCustomBackgroundImage:(UIImage*)image;
- (void)removeCustomBackgroundImage;

- (void)showCustomBackgroundImage;
- (void)hideCustomBackgroundImage;

@end
