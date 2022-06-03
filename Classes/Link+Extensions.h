//
//  Link+Extensions.h
//  appbuildr
//
//  Created by William Johnson on 10/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Link.h"


@interface Link(Extensions) 

- (BOOL) hasHttpLiveStreaming;
- (BOOL) hasAudio;
- (BOOL) hasImage;
- (BOOL) hasVideo;
- (BOOL) hasMedia;
- (NSString *)getHrefExtension;

@end
