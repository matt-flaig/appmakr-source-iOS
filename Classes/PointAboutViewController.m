//
//  PointAboutViewController.m
//  Kaplan
//
//  Created by William M. Johnson on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointAboutViewController.h"
#import "PointAboutTabBarScrollViewController.h"

@implementation PointAboutViewController
@synthesize pointAboutTabBarScrollViewController;
-(UINavigationController *)navigationController
{
	if (pointAboutTabBarScrollViewController != nil) 
	{
		return pointAboutTabBarScrollViewController.navigationController;
	}
	
	return super.navigationController;	
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.pointAboutTabBarScrollViewController = nil;
    }
    return self;
}

- (id)init
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
		
    }
    return self;
}

-(UIButton *) tabBarButton {
	if(!tabBarButton) {
		tabBarButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	}
	return tabBarButton;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[pointAboutTabBarScrollViewController release];
	[tabBarButton release];
    [super dealloc];
}


@end
