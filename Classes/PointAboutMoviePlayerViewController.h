//
//  PointAboutMoviePlayerViewController.h
//  MoviePlayer
//
//  Created by William M. Johnson on 8/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PointAboutMoviePlayerViewController : MPMoviePlayerViewController 
{
	
	IBOutlet UIView * statusView;
	IBOutlet UIButton * cancelButton;
	IBOutlet UIActivityIndicatorView * spinner;
	IBOutlet UILabel * loadingLabel;
	
}

-(IBAction) cancelButtonPressed:(id)sender;
@end
