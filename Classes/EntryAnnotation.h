//
//  StoryAnnotation.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/8/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "Entry.h"
@interface EntryAnnotation :NSObject<MKAnnotation> {
	Entry * entry;
	NSInteger entryIndex;
}
@property(nonatomic) NSInteger entryIndex;

-(id) initWithEntry:(Entry *)aEntry;

@end
