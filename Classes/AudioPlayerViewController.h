//
//  AudioPlayerViewController.h
//  appbuildr
//
//  Created by Brian Schwartz on 2/3/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>;
#import "AudioPlayerView.h"

@interface AudioPlayerViewController : UIViewController {

	AVAudioPlayer *audioPlayer;
	AudioPlayerView *audioView;
	bool showPlayer;
}



@end
