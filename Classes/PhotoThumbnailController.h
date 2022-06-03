//
//  PhotoAlbumScrollController.h
//  politico
//
//  Created by PointAbout Dev on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "PhotoAdsDetailView.h"
#import "StreamThumbnailController.h"

@class PhotoDataSource;
@class SZPathBar;

@interface PhotoThumbnailController : StreamThumbnailController<MWPhotoBrowserViewDelegate, StreamThumbnailControllerDelegate>
{
	NSMutableArray			*imageButtons;
	NSMutableDictionary		*buttonDictionary;
    SZPathBar               *bar;
}

-(id)initWithFeedURL:(NSString *) streamFeedURL title:(NSString *)aTabTitle;

@end
