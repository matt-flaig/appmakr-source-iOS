//
//  AppMakrJob.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/21/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrCoreDataOperation.h"
#import "NetworkReadyOperation.h"

@implementation AppMakrCoreDataOperation

-(void)dealloc {
    [managedObject release];
    [localDataStore release];
    [super dealloc];
}
-(id) initWithUniqueID:(NSString *)uniqueObjectID {
    if( (self = [super initWithUniqueID:uniqueObjectID]) ) {
        DebugLog(@"### starting a appmakr operation %@", uniqueObjectID);
        localDataStore = [[DataStore alloc]init];
        NSURL *objectIDURL = [NSURL URLWithString:uniqueObjectID];
        managedObject = [(NSManagedObject *)[localDataStore entityWithID:objectIDURL] retain];
        return self;
    }
    return nil;
}
@end
