//
//  MoviePlayer.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MoviePlayerController.h"
#import "NetworkCheck.h"
#import "appbuildrAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@implementation MoviePlayerController

@synthesize link, moviePlayer;

static MoviePlayerController* moviePlayerController;

- (void)dealloc {
	[moviePlayer release];
	[link release];
	[customActivityView release];
    [super dealloc];
}


+ (MoviePlayerController *)getMoviePlayer {
	@synchronized(self) {
        if (moviePlayerController == nil) {
            moviePlayerController = [[self allocWithZone:NULL] init] ; // assignment not done here
        }
    }
    return moviePlayerController;
	
}
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (moviePlayerController == nil) {
            moviePlayerController = [super allocWithZone:zone];
            return moviePlayerController;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

-(id)init {
	if((self = [super init]) ) {
		
	}
	return self;
	
}

-(void) initializeMPMovieController {
	if( !moviePlayer ) {
		moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://"] ];	
		[moviePlayer stop];		
		if ([moviePlayer respondsToSelector:@selector(setControlStyle:)])
		{
			//	moviePlayer.controlStyle =   MPMovieControlStyleFullscreen;
			
		}
		if ([moviePlayer respondsToSelector:@selector(view)]) 
		{
			moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			moviePlayer.view.autoresizesSubviews = YES;		
		}
		
		moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
		customActivityView = [[CustomActivityView alloc] initWithTitle:@"Loading Media..."];
	}
}
- (void) playVideoWithLink:(Link *)mediaLink videoView:(UIView *) view {
	[self initializeMPMovieController];
	
	self.link = mediaLink;
	
	[moviePlayer stop];
	
	if ( [link hasHttpLiveStreaming] || [NetworkCheck hasWiFi] || [link hasAudio] ) {
		appbuildrAppDelegate* appDelegate  = (appbuildrAppDelegate * )[UIApplication sharedApplication].delegate;		

		customActivityView.frame = CGRectMake(appDelegate.window.center.x-75,appDelegate.window.center.y-75,150,150);
		customActivityView.hidden = NO;
		[appDelegate.window addSubview:customActivityView];
		
		DebugLog(@"movie url %@", link.href);
		if ([moviePlayer respondsToSelector:@selector(view)]) 
		{
			
			[moviePlayer.view removeFromSuperview];
			
			CGRect movieFrame = view.bounds;
			moviePlayer.view.frame = movieFrame; 
			[view addSubview: moviePlayer.view];
			[view bringSubviewToFront:moviePlayer.view];
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:)
														 name:MPMoviePlayerLoadStateDidChangeNotification
													   object:moviePlayer];
			
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:moviePlayer];
		
						
		[moviePlayer play];		
	} else {
		UIAlertView *errorWIFI = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"This Media File Requires WiFi to Play Within %@", 
																	 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] 
															message:@"Would you like to play this media file in the Safari app instead?"
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
		[errorWIFI show];
		[errorWIFI release];
	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	if(buttonIndex == 0){
		NSURL * theURL = [NSURL URLWithString:link.href];
		[[UIApplication sharedApplication] openURL:theURL];	
	}
}


-(void)playerLoadStateDidChange:(NSNotification *)notification {
	customActivityView.hidden = YES;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerLoadStateDidChangeNotification
												  object:moviePlayer];
}


// When the movie is done, release the controller.
-(void)movieFinishedCallback:(NSNotification*)aNotification
{
	
	//theMovie.view.hidden = YES;
	// set initialPlaybackTime property of the MPMoviePlayerController class to -1.0 to prevent continued playback in case user closes
	// movie player before pre loading has finished.
	
	if ([moviePlayer respondsToSelector:@selector(view)]) 
	{
		[moviePlayer.view removeFromSuperview];
    }
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayer];

}
@end
