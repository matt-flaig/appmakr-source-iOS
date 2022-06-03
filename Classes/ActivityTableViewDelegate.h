//
//  ActivityTableViewDelegate.h
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityBaseViewController.h"

@interface ActivityTableViewDelegate : NSObject <UITableViewDelegate>
{
	
	ActivityBaseViewController * activityController;

}

@property (nonatomic,retain) 	ActivityBaseViewController * activityController;  //This should be readonly but for now, i'm retaining for simplicity.


@end
