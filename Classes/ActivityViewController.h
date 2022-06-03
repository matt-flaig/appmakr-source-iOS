//
//  ActivityViewController.h
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityBaseViewController.h"
#import "ActivityMapViewController.h"

@interface ActivityViewController : ActivityBaseViewController<NavigationControllerDelegate> 
{
    BOOL                        _isMapDisplayed;
    ActivityMapViewController   *myMapView;
	IBOutlet UISegmentedControl *locationOptions;
    BOOL                        containsAMapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil displayMap:(BOOL)displayMap;

@end
