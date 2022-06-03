//
//  AppMakrJob.h
//  appbuildr
//
//  Created by Isaac Mosquera on 3/21/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "DataStore.h"
#import "AppMakrOperation.h"


@interface AppMakrCoreDataOperation : AppMakrOperation {
    NSManagedObject *managedObject;
    DataStore *localDataStore;
}
-(id) initWithUniqueID:(NSString *)uniqueObjectID;
@end
