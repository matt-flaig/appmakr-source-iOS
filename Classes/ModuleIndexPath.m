//
//  ModuleIndexPath.m
//  appbuildr
//
//  Created by Sergey Popenko on 2/6/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "ModuleIndexPath.h"

@implementation ModuleIndexPath
@synthesize moduleIndex = _moduleIndex;
@synthesize childIndex = _childIndex;

-(void)dealloc
{
    self.moduleIndex = nil;
    self.childIndex = nil;
    [super dealloc];
}

+(ModuleIndexPath*) createWithIndex:(NSNumber*) mid childIndex: (NSNumber*)cid
{
    ModuleIndexPath* index = [[[ModuleIndexPath alloc] init] autorelease];
    index.moduleIndex = mid;
    index.childIndex = cid;
    return index;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[ModuleIndexPath createWithIndex:self.moduleIndex childIndex:self.childIndex] retain];    
}

@end
