//
//  Feed.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

@class Entry;
@class FeedGeoPoint;
@class FeedLink;

@interface Feed :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet* entries;
@property (nonatomic, retain) NSSet* links;
@property (nonatomic, retain) FeedGeoPoint * geoPoint;
@property (nonatomic, retain) NSString * moduleType;

@end


@interface Feed (CoreDataGeneratedAccessors)
- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)value;
- (void)removeEntries:(NSSet *)value;

- (void)addLinksObject:(FeedLink *)value;
- (void)removeLinksObject:(FeedLink *)value;
- (void)addLinks:(NSSet *)value;
- (void)removeLinks:(NSSet *)value;

@end

