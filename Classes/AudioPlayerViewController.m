//
//  AudioPlayerViewController.m
//  appbuildr
//
//  Created by Brian Schwartz on 2/3/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AudioPlayerViewController.h"


@implementation AudioPlayerViewController



 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
	if (self = [super initWithNibName:nil bundle:nil]) {
        
		AVAudioPlayer *aAudioPlayer = [[AVAudioPlayer alloc] init];
		audioPlayer = aAudioPlayer;
		[aAudioPlayer release];
		
		AudioPlayerView *aAudioView = [[AudioPlayerView alloc] init];
		audioView = aAudioView;
		[aAudioView release];
		
		showPlayer = NO;
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [audioView release];
	[audioPlayer release];
	[super dealloc];
}


@end
