//
//  AppMakrShareActionSheet.h
//  appbuildr
//
//  Created by Sergey Popenko on 11/23/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocializeModalViewCallbackDelegate.h"
#import <MessageUI/MessageUI.h>

@class Entry;
@class SocializeModalViewController;

@interface AppMakrShareActionSheet : UIActionSheet<SocializeModalViewCallbackDelegate, MFMailComposeViewControllerDelegate>
{
    SocializeModalViewController* _modalViewController;
    __weak Entry* _entry; 
}

// Keep attention that Entry is NSManagment object and will be enabled only while context is availiable
+(AppMakrShareActionSheet*)actionSheetForEntry:(Entry*)entry configurationBlock: (void (^)(AppMakrShareActionSheet*)) block;

@property(nonatomic, assign) BOOL facebookShare;
@property(nonatomic, assign) BOOL twitterShare;
@property(nonatomic, assign) BOOL mailShare;
@property(nonatomic, assign) BOOL appMakrPublish;
@property(nonatomic, assign) UIViewController* parentController;
@end
