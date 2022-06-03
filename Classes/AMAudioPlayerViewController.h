//
//  AMAudioPlayerViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/24/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol AMAudioPlayerViewControllerDelegate;

@interface AMAudioPlayerViewController : UIViewController {

	IBOutlet UISlider *audioProgressSlider;

	IBOutlet UILabel *durationLabel;
	IBOutlet UILabel *currentTimeLabel;
	IBOutlet UIButton *playButton;
	IBOutlet UIButton *pauseButton;
	IBOutlet UIImageView *progressBorder;
	IBOutlet UIActivityIndicatorView *activityView;
	AVPlayer *audioPlayer;
	
	id periodicObserver;
	id<AMAudioPlayerViewControllerDelegate> delegate;
}
-(void)loadAudioURL:(NSURL *)audioURL;
-(IBAction)closeButtonPressed:(id)control;
-(IBAction)audioControlButtonPressed:(id)control;
-(IBAction)audioSliderSeek:(id)control;
+ (AMAudioPlayerViewController *)sharedInstance;
@property (assign) id<AMAudioPlayerViewControllerDelegate> delegate;

@end

@protocol AMAudioPlayerViewControllerDelegate <NSObject>
@optional
-(void)audioWillLoad:(AMAudioPlayerViewController *)audioPlayer;
-(void)audioDidLoad:(AMAudioPlayerViewController *)audioPlayer;
-(void)audioError:(AMAudioPlayerViewController *)audioPlayer audioError:(NSError *)error;
-(void)audioWillStop:(AMAudioPlayerViewController *)audioPlayer;
-(void)audioWillStop:(AMAudioPlayerViewController *)audioPlayer;
-(void)audioCloseButtonPressed:(AMAudioPlayerViewController *)audioPlayer;
@end

