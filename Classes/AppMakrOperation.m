//
//  AMOperation.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/25/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrOperation.h"
#import "NetworkReadyOperation.h"

//the timeout is in seconds, not milliseconds
const int kAMOperationRetryTimeout = 10;

@implementation AppMakrOperation
@synthesize objectID, status;

-(void) dealloc {
    [objectID release];
    [super dealloc];
}

-(id) initWithUniqueID:(NSString *)uniqueObjectID {
    if( (self = [super init]) ) {
        objectID = [uniqueObjectID retain];
        
        NetworkReadyOperation *networkOperation = [[NetworkReadyOperation alloc]init];
        [self addDependency:networkOperation];
        [networkOperation release];
        return self;
    }
    return nil;
}

@end
