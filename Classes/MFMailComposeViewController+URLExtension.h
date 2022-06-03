//
//  MFMailComposeViewController+URLExtension.h
//  appbuildr
//
//  Created by Fawad Haider  on 12/1/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>


@interface MFMailComposeViewController(URLExtension)
+ (MFMailComposeViewController*)composerWithInfoFromUrl:(NSURL*)url withDelegate:(id<MFMailComposeViewControllerDelegate>)controllerDelegate;
@end
