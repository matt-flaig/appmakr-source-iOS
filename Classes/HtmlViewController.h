//
//  HtmlViewController.h
//  appbuildr
//
//  Created by Sergey Popenko on 2/15/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterController.h"
#import "AdsControllerDelegate.h"

@class SZPathBar;
@interface HtmlViewController : MasterController<UIWebViewDelegate, AdsControllerCallback>{
    SZPathBar* bar;
}

@property(nonatomic, retain) NSString* pageName;
@end
