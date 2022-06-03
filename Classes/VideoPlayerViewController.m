//This file is part of MyVideoPlayer.
//
//MyVideoPlayer is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//MyVideoPlayer is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with MyVideoPlayer.  If not, see <http://www.gnu.org/licenses/>.

#import "VideoPlayerViewController.h"
#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

/* Asset keys */
NSString * const kTracksKey = @"tracks";
NSString * const kPlayableKey = @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kCurrentItemKey	= @"currentItem";

@interface VideoPlayerViewController ()

@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerItem *playerItem;

-(AVAudioMix*) audioControll: (AVURLAsset*) asset;

@end

static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation VideoPlayerViewController

@synthesize URL = _URL;
@synthesize player = _player;
@synthesize playerItem = _playerItem;

#pragma mark - UIView lifecycle

- (void)loadView {
    VideoPlayerView *playerView = [[VideoPlayerView alloc] init];
    self.view = playerView;
    [playerView release];
}

#pragma mark - Memory Management

- (void)dealloc {
    [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    [self.player.currentItem removeObserver:self forKeyPath:kStatusKey];
	[self.player pause];
    
    self.URL = nil;
    self.player = nil;
    self.playerItem = nil;
    
    [super dealloc];
}


#pragma mark - Private methods

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    for (NSString *thisKey in requestedKeys) {
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed) {
			return;
		}
	}

	if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];            
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
	
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    // Choose a category identifier for audio sessions
    UInt32 sessionCategory = kAudioSessionCategory_SoloAmbientSound;
    
    // Set the session property and respect device audio settings
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory), &sessionCategory);
    
    //  MUTE the video stream
    //[self.playerItem setAudioMix:[self audioControll:asset]];
    [self.playerItem addObserver:self 
                       forKeyPath:kStatusKey 
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
		
    if (![self player]) {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];	
        [self.player addObserver:self 
                      forKeyPath:kCurrentItemKey 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
    }
    
    if (self.player.currentItem != self.playerItem) {
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}

-(AVAudioMix*) audioControll: (AVURLAsset*) asset
{
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =[AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    return audioZeroMix;
}

#pragma mark - Key Valye Observing

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)observeValueForKeyPath:(NSString*) path 
                      ofObject:(id)object 
                        change:(NSDictionary*)change 
                       context:(void*)context {
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {

            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone; 
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[self.player currentItem]];
            
            [self.player play];
        }
	} else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
            [(VideoPlayerView*)self.view setPlayer:self.player];
            [(VideoPlayerView*)self.view setVideoFillMode:AVLayerVideoGravityResizeAspectFill];
        }
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


#pragma mark - Public methods

- (void)setURL:(NSURL*)URL {
    [_URL release];
    _URL = [URL copy];
    

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_URL options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];

    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{		 
         dispatch_async( dispatch_get_main_queue(), 
                        ^{
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

- (NSURL*)URL {
	return _URL;
}


-(void)play
{
    [self.player play];
}

-(void)pause
{
    [self.player pause];
}

-(void)setBackgroundImage:(UIImage*)image scale:(UIViewContentMode) fillMode
{
    [(VideoPlayerView*)self.view setBackgroundImage:image fillMode:UIViewContentModeScaleAspectFill];
}


-(UIImage*) getImageOnTime:(CMTime) timePoint
{   
    AVAsset* asset =  [AVURLAsset URLAssetWithURL:self.URL options:nil];;
    
    UIImage* image = nil;
    if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:timePoint actualTime:&actualTime error:&error];
        
        if (imageRef != NULL) {
            
            image = [UIImage imageWithCGImage:imageRef];
            
            CGImageRelease(imageRef);
        }
    }
    
    return image;
}
@end
