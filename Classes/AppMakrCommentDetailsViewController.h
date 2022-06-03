//
//  AppmakrCommentDetailsViewController.h
//  appbuildr
//
//  Created by Sergey Popenko on 4/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class AppMakrCommentDetailsView;
@class EntryComment;
@class AppMakrURLDownload;

@interface AppmakrCommentDetailsViewController : UIViewController<MKReverseGeocoderDelegate> 
{
    @private
        AppMakrURLDownload *profileImageDownloader;
        MKReverseGeocoder *geoCoder;
        IBOutlet AppMakrCommentDetailsView* commentDetailsView;
        EntryComment* entryComment;
}

@property (nonatomic, retain) IBOutlet AppMakrCommentDetailsView* commentDetailsView;
@property (nonatomic, retain) EntryComment* entryComment;

-(IBAction)viewProfileButtonTouched:(id)sender;

@end
