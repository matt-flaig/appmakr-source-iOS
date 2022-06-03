//
//  PointAboutNavigationController+Socialize.m
//  appbuildr
//
//  Created by William M. Johnson on 4/7/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "PointAboutNavigationController+Socialize.h"
#import "AppMakrUINavigationBarBackground.h"


@implementation PointAboutNavigationController (Socialize)

+(PointAboutNavigationController *) socializeNavigationControllerWithRootViewController:(UIViewController *) rootViewController
{
   
    UIImage * socializeNavBarBackground = [UIImage imageNamed:@"socialize_resources/socialize-navbar-bg.png"];
	
	PointAboutNavigationController * profileNavigationController = [[PointAboutNavigationController alloc]initWithRootViewController:rootViewController]; 
    
    [profileNavigationController.navigationBar setCustomBackgroundImage:socializeNavBarBackground];
	
    return [profileNavigationController autorelease];
}

@end
