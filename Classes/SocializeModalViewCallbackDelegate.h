//
//  SocializeModalViewCallbackDelegate.h
//  appbuildr
//
//  Created by Fawad Haider  on 11/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@protocol SocializeModalViewCallbackDelegate

-(void)dismissModalView:(UIView*)myView;

@optional
-(void)dismissModalView:(UIView*)myView andPostComment:(NSString*)comment forEntry:(Entry*)entry;
-(void)dismissModalView:(UIView*)myView andPushNewModalController:(UIViewController*)newSocializeModalController;
-(void)shareViaEmail;
-(void)dismissModalView:(UIView*)myView andPostToFacebook:(NSString*)comment;
-(void)dismissModalView:(UIView*)myView andPostToTwitter:(NSString*)comment;
@end
