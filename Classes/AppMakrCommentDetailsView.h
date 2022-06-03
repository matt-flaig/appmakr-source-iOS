//
//  AppMakrCommentDetailsView.h
//  appbuildr
//
//  Created by Sergey Popenko on 4/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppMakrCommentMapView;

@interface AppMakrCommentDetailsView : UIScrollView <UIWebViewDelegate> {
    IBOutlet UIWebView* commentMessage;
    IBOutlet AppMakrCommentMapView* mapOfUserLocation;
    IBOutlet UIImageView* navImage;
    IBOutlet UILabel* positionLable;
    IBOutlet UIButton* profileNameButton;
    IBOutlet UILabel* profileNameLable;
    IBOutlet UIImageView* profileImage;
    IBOutlet UIImageView* shadowBackground;
    
    BOOL showMap;
}

@property (nonatomic, retain) IBOutlet UIWebView* commentMessage; 
@property (nonatomic, retain) IBOutlet AppMakrCommentMapView* mapOfUserLocation;
@property (nonatomic, retain) IBOutlet UIImageView* navImage;
@property (nonatomic, retain) IBOutlet UILabel* positionLable;
@property (nonatomic, retain) IBOutlet UIButton* profileNameButton;
@property (nonatomic, retain) IBOutlet UILabel* profileNameLable;
@property (nonatomic, retain) IBOutlet UIImageView* profileImage;
@property (nonatomic, retain) IBOutlet UIImageView* shadowBackground;
@property (nonatomic, assign) BOOL showMap;

-(void) updateProfileImage: (UIImage* )image;
-(void) configurateProfileImage;

@end