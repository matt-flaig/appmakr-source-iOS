//
//  EntryCommentGeoPoint.h
//  appbuildr
//
//  Created by William Johnson on 11/23/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class EntryComment;

@interface EntryCommentGeoPoint :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) EntryComment * EntryComment;

@end



