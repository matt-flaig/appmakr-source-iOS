//
//  PhotoDataSource.h
//  appbuildr
//
//  Created by Sergey Popenko on 3/27/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "MWPhotoBrowser.h"

@interface PhotoDataSource : NSObject<MWPhotoBrowserDelegate>
-(id)initWithFeed:(Feed*)feed;
-(Entry*) entryAtIndex:(NSUInteger)index;
@end
