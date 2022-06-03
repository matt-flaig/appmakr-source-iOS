//
//  AMAudioPlayerViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/24/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AMAudioPlayerViewController.h"
#import "UILabel-Additions.h"

AMAudioPlayerViewController *sharedInstance;


@interface AMAudioPlayerViewController(Internal)
-(void) updateAudioStatus:(CMTime)time;
-(void)resetAudioPlayer;
@end

@implementation AMAudioPlayerViewController
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {	
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidPlayToEnd) 
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:nil];
	
	self.view.backgroundColor = [UIColor clearColor];
	UIImage *progressBorderImage = [[UIImage imageNamed:@"socialize_resources/audio_player/audiobar-progress-border.png"]
									stretchableImageWithLeftCapWidth:8.0 topCapHeight:0.0];
	progressBorder.image = progressBorderImage;
	
	//SET THE LABELS TO NOTHING
	currentTimeLabel.text = @"";
	durationLabel.text = @"";
	[currentTimeLabel applyBlurAndShadow];
	[durationLabel applyBlurAndShadow];
	
	[audioProgressSlider setThumbImage: [UIImage imageNamed:@"socialize_resources/audio_player/audiobar-progress-scrubber.png"] forState:UIControlStateNormal];
	UIImage *stetchLeftTrack = [[UIImage imageNamed:@"socialize_resources/audio_player/audiobar-progress-bar.png"]
								stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
	UIImage *stetchRightTrack = [[UIImage imageNamed:@"socialize_resources/audio_player/max_track.png"]
								 stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
	[audioProgressSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
	[audioProgressSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
	[audioProgressSlider setValue:0.0f animated:true];

	currentTimeLabel.text = @"0:00";
	durationLabel.text = @"0:00";

//	audioControlButton.adjustsImageWhenHighlighted = NO;	
}
-(void) playerItemDidPlayToEnd {
	CMTime seekTime = CMTimeMake(0,1);
	[audioPlayer seekToTime:seekTime];
	[audioProgressSlider setValue:0.0 animated:YES];
}
-(IBAction)closeButtonPressed:(id)control {
	if( delegate ) {
		[delegate audioCloseButtonPressed:self];
	}
}

-(void)resetAudioPlayer {
	if( periodicObserver ) {
		[audioPlayer removeTimeObserver:periodicObserver];
		[periodicObserver release];
		periodicObserver = nil;
	}
	[audioPlayer release];	
	audioPlayer = nil;	
}
-(void)loadAudioURL:(NSURL *)audioURL {
	DebugLog(@"loading audio player");
	if( audioPlayer ) {
		[self resetAudioPlayer];
	}
	playButton.hidden = YES;
	pauseButton.hidden = YES;
	activityView.hidden = NO;
	[activityView startAnimating];

	audioPlayer = [[AVPlayer alloc] initWithURL:audioURL];

	if(audioPlayer) {		
		if(self.delegate) {
			[self.delegate audioWillLoad:self];
	    }
		[audioPlayer play];		
		periodicObserver = [audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 25)
													queue:NULL
												usingBlock:^(CMTime time){
													[self updateAudioStatus:time]; 
													   }];
		[periodicObserver retain]; 
	} else {	
		DebugLog(@"error when trying to player audio in AMAudioPlayer");
	}
}


-(NSString *) getFormattedTime:(CMTime)time {
	float currentTime = ((float)time.value/(float)time.timescale);
	int minutes = 0;
	int seconds = 0;
	if( currentTime > 0.0 ) {
		minutes = currentTime/60;
		seconds = (int)currentTime % 60;
	}
	return [NSString stringWithFormat:@"%i:%02d",minutes, seconds];
}
-(void) updateAudioStatus:(CMTime)time {
	if( audioPlayer.currentItem.status == AVPlayerItemStatusFailed ) {
		DebugLog(@"status failed");
		[self resetAudioPlayer];	
		if( delegate ) {
			[delegate audioError:self audioError:audioPlayer.currentItem.error];
		}
		UIAlertView *uiAlert = [[UIAlertView alloc]
								initWithTitle:@"Audio Error" message:@"There was an error loading your audio" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[uiAlert show]; 
		[uiAlert release];	
	}
	else if( audioPlayer.currentItem.status == AVPlayerItemStatusUnknown ) {
		activityView.hidden = NO;
		playButton.hidden = YES;
		pauseButton.hidden = YES;
	}  else if ( audioPlayer.currentItem.status == AVPlayerStatusReadyToPlay ) {
		if( audioPlayer.rate == 0.0 ) {
			playButton.hidden = NO;
			pauseButton.hidden = YES;
		} else  {
			playButton.hidden = YES;
			pauseButton.hidden = NO;
		}
		activityView.hidden = YES;
		CMTime durationCMTime = audioPlayer.currentItem.asset.duration;
		currentTimeLabel.text = [self getFormattedTime:time];
		durationLabel.text = [self getFormattedTime:durationCMTime];
		
		audioProgressSlider.maximumValue = ((float)durationCMTime.value/(float)durationCMTime.timescale);
		
		if( !audioProgressSlider.tracking ) {
			float currentTime = ((float)time.value/(float)time.timescale);
			[audioProgressSlider setValue:currentTime animated:true];
		}
	} 
	
}
-(IBAction)audioSliderSeek:(id)control {
	DebugLog(@" the value should be: %f", audioProgressSlider.value);
	CMTime seekTime = CMTimeMake(audioProgressSlider.value,1);
	[audioPlayer seekToTime:seekTime];
}
-(IBAction)audioControlButtonPressed:(id)control {
	UIButton *audioControl = (UIButton *)control;
	DebugLog(@"control button touched");
	if( audioControl.tag == 1 ) {
		[audioPlayer pause];
	} else {
		[audioPlayer play];
	}
	
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

+ (AMAudioPlayerViewController *)sharedInstance {
	@synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[AMAudioPlayerViewController alloc] initWithNibName:@"AMAudioPlayerViewController" bundle:nil];
		
    }
    return sharedInstance;
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}
- (oneway void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}


- (void)dealloc {
	[durationLabel release];
	[currentTimeLabel release];
	[periodicObserver release];
	[audioPlayer release];
	[audioProgressSlider release];
	[playButton release];
	[pauseButton release];
    [super dealloc];
}


@end
