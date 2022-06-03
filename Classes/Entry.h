//
//  Entry.h
//  appbuildr
//
//  Created by William Johnson on 11/23/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class EntryComment;
@class EntryGeoPoint;
@class EntryImageReference;
@class EntryLink;
@class Feed;
@class Statistics;

@protocol Entry //Added to implemet mock objects
    @property (nonatomic, retain) NSString * fullSizedImageURL;
    @property (nonatomic, retain) NSString * title;
    @property (nonatomic, retain) NSDate * expirationDate;
    @property (nonatomic, retain) NSNumber * useHost;
    @property (nonatomic, retain) NSString * summary;
    @property (nonatomic, retain) NSString * guid;
    @property (nonatomic, retain) NSNumber * liked;
    @property (nonatomic, retain) NSString * url;
    @property (nonatomic, retain) NSString * mediaSummary;
    @property (nonatomic, retain) NSString * updated;
    @property (nonatomic, retain) NSString * type;
    @property (nonatomic, retain) NSString * formattedDescription;
    @property (nonatomic, retain) NSDate * lastViewDate;
    @property (nonatomic, retain) NSString * thumbnailURL;
    @property (nonatomic, retain) NSNumber * order;
    @property (nonatomic, retain) NSString * author;
    @property (nonatomic, retain) NSString * content;
    @property (nonatomic, retain) EntryGeoPoint * geoPoint;
    @property (nonatomic, retain) Feed * feed;
    @property (nonatomic, retain) Statistics * statistics;
    @property (nonatomic, retain) EntryImageReference * fullSizedImage;
    @property (nonatomic, retain) NSSet* links;
    @property (nonatomic, retain) EntryImageReference * thumbnailImage;
    @property (nonatomic, retain) NSSet* comments;

    @optional
    - (NSArray *)linksInOriginalOrder;
@end

@interface Entry :  NSManagedObject<Entry>  
{
}

@property (nonatomic, retain) NSString * fullSizedImageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSNumber * useHost;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * mediaSummary;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * formattedDescription;
@property (nonatomic, retain) NSDate * lastViewDate;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) EntryGeoPoint * geoPoint;
@property (nonatomic, retain) Feed * feed;
@property (nonatomic, retain) Statistics * statistics;
@property (nonatomic, retain) EntryImageReference * fullSizedImage;
@property (nonatomic, retain) NSSet* links;
@property (nonatomic, retain) EntryImageReference * thumbnailImage;
@property (nonatomic, retain) NSSet* comments;

@end


@interface Entry (CoreDataGeneratedAccessors)
- (void)addLinksObject:(EntryLink *)value;
- (void)removeLinksObject:(EntryLink *)value;
- (void)addLinks:(NSSet *)value;
- (void)removeLinks:(NSSet *)value;

- (void)addCommentsObject:(EntryComment *)value;
- (void)removeCommentsObject:(EntryComment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

@end

