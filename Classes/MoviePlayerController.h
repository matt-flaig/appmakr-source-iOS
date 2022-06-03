//
//  MoviePlayer.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/19/09.
//  Copyright 2009 PointAbout. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "FeedObjects.h"
#import "CustomActivityView.h"

@interface MoviePlayerController : NSObject {
	MPMoviePlayerController	*moviePlayer;
	Link					*link;
	CustomActivityView		*customActivityView;
}

@property(nonatomic, retain) Link	*link;
@property(nonatomic, retain) MPMoviePlayerController* moviePlayer;

-(void)movieFinishedCallback:(NSNotification*)aNotification;
-(void)playVideoWithLink:(Link *)mediaLink videoView:(UIView *) view;
-(void)initializeMPMovieController;

+ (MoviePlayerController *)getMoviePlayer;
@end
