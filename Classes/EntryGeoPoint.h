//
//  EntryGeoPoint.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import "GeoPoint.h"

@class Entry;

@interface EntryGeoPoint : GeoPoint 
{
}

@property (nonatomic, retain) Entry * entry;

@end



