//
//  PhotoDataSource.m
//  appbuildr
//
//  Created by Sergey Popenko on 3/27/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "PhotoDataSource.h"
#import "Entry.h"
#import "Feed+Extensions.h"

@interface PhotoDataSource()
    @property (nonatomic, retain) NSArray* entries;
    @property (nonatomic, retain) NSManagedObjectContext* context;
@end

@implementation PhotoDataSource

@synthesize entries = _entries;
@synthesize context = _context;

-(void)dealloc
{
    self.entries = nil;
    self.context = nil;
    [super dealloc];
}

-(id)initWithFeed:(Feed*)feed
{
    self = [super init];
    if(self)
    {
        NSAssert(feed != nil, @"Feed var could not be nil");
        
        self.entries = [feed entriesInOriginalOrder];
        self.context = feed.managedObjectContext;
    }
    return self;
}

-(Entry*) entryAtIndex:(NSUInteger)index
{
    return [self.entries objectAtIndex:index];
}

#pragma mark MWPhotoBrowserDelegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.entries.count;
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.entries.count)
    {  
        NSString* urlString = [[self entryAtIndex:index]fullSizedImageURL];
        MWPhoto* photo = [MWPhoto photoWithURL:[NSURL URLWithString:urlString]];
        photo.caption = [[self entryAtIndex:index] title];
        return photo;
    }
    return nil;
}

@end
