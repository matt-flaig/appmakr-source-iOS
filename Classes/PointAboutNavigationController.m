//
//  PointAboutNavigationController.m
//  appbuildr
//
//  Created by William Johnson on 12/20/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "PointAboutNavigationController.h"


@implementation PointAboutNavigationController

@synthesize pointAboutTabBarScrollViewController;

-(UIButton *) tabBarButton {
	if(!tabBarButton) {
		tabBarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	return tabBarButton;
}



//-(UIViewController *)parentViewController
//{
//	if (self.pointAboutTabBarScrollViewController != nil) 
//	{
//		return self.pointAboutTabBarScrollViewController;
//	}
//	
//	UIViewController * controller = [super parentViewController];
//	
//	return controller;
//	
//}


-(void)dealloc
{
	[pointAboutTabBarScrollViewController release];
	[super dealloc];
}

@end
