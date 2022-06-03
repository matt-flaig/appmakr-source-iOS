//
//  EntryComment.h
//  appbuildr
//
//  Created by William Johnson on 11/23/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Entry;
@class EntryCommentGeoPoint;

@interface EntryComment :  NSManagedObject  
{
   
}

@property (nonatomic, retain) NSNumber * medium;
@property (nonatomic, retain) NSString * commentText;
@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) NSNumber * appID;
@property (nonatomic, retain) NSString * userImageURL;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) EntryCommentGeoPoint * geoPoint;
@property (nonatomic, retain) Entry * Entry;

@end



