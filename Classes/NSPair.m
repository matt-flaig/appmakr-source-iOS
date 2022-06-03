//
//  NSPair.m
//  appbuildr
//
//  Created by Mac on 19.03.12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import "NSPair.h"

@implementation NSPair
@synthesize first;
@synthesize second;

-(void) dealloc
{
    self.first = nil;
    self.second = nil;
    [super dealloc];
}
@end
