//
//  FeedLink.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import "Link.h"

@class Feed;

@interface FeedLink : Link  
{
}


@property (nonatomic, retain) Feed * feed;

@end



