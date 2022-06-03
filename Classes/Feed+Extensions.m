//
//  Feed+Extensions.m
//  appbuildr
//
//  Created by William Johnson on 10/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Feed+Extensions.h"
#import "Link.h"

@implementation Feed(Extensions)

+(NSArray *)sortedArray:(NSArray *)arrayToSort
{
	
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"order" ascending:YES ]autorelease];	
	return [arrayToSort sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
}	

-(NSArray *)entriesInOriginalOrder
{
	NSArray * entryArray =[self.entries allObjects];
    return [Feed sortedArray:entryArray];
	
}

-(NSArray *)linksInOriginalOrder
{
	return [Feed sortedArray:[self.links allObjects]];
}

- (void)addLinksFromArray:(NSArray *)value
{
    for (int i = 0; i< [value count]; i++) {
        Link* link = (Link*)[value objectAtIndex:i];
        link.order = [NSNumber numberWithInt: i];
    }
    [self addLinks:[NSSet setWithArray:value]];
}
@end
