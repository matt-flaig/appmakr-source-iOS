//
//  CoreDataRepository.h
//  Disney
//
//  Created by PointAbout Dev on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ObjectRepositoryProtocol.h"


@interface CoreDataRepository : NSObject <ObjectRepositoryProtocol>
{
			

		NSManagedObjectContext *managedObjectContext_;
		NSManagedObjectModel *managedObjectModel_;
		NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

+ (NSString *)applicationDocumentsDirectory;
+ (NSString *)applicationCacheDirectory;
+ (void) wipeout;
@end
