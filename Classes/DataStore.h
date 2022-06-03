//
//  AppData.h
//
//  Created by Rolf Hendriks on 4/8/10.
//  Copyright 2010 PointAbout Inc. All rights reserved.
//
//	A high level API providing simple access to anything data related
//
//	Provides simple data access methods which abstract away from the underlying data store
//		default implementation is Core Data using an SQLite backend, but this should be switchable without 
//		affecting other modules.
//

#import <Foundation/Foundation.h>

@protocol ObjectRepositoryProtocol;

@interface DataStore : NSObject 
{
	id<ObjectRepositoryProtocol> s_repository;	
}

// initialize / shutdown
// need to call initialize before calling any other methods
// need to call shutdown on app exit
+ (void) initializeDataStore;
+ (void) shutdown;
+ (DataStore *) defaultStore;

// saving / loading objects


// createEntityForClass:
//	used to initially create an instance of an entity / managed object to put into the database
//	result type is the class CoreData automatically constructs from the object model
//	need to save changes for the object creation to be committed to the database.
//		input: name of table / entity to create
//		output: an instance of the class representing the given entity / table
 - (NSObject*) createObjectOfClass:(Class)aClass;
 
 // save:
 //	commits all changes made to the database since last time (insertions, deletes, updates)
 - (BOOL) save;
 - (BOOL) save:(NSError **)error;
 // refreshObject:
 //	frees an object from Core Data memory
 - (void) refreshEntity:(NSManagedObject*)object;
 
 // deleting entities
-  (void) deleteEntities:(NSSet *)entitiesToDelete;
 - (void) deleteEntity:(NSManagedObject*)entity;
 
 // wipe out everything!
 //	should be done before data store is accessed 1st time
 - (void) wipeout;
 
 
 // multithreading support
 //	when accessing data store from multiple threads simultaneously, need to lock and unlock every time you use it!
 - (void) lock;
 - (void) unlock;
 
 
 // general reusable queries
 // Note on results:
 //	the below methods handle errors automatically.
 //	if an error occurs during the query, the return value is nil
 //	if no error occurs but the query yields no results, the return value is an empty array
 
 // get all objects of a given type
 - (NSArray*) retrieveEntityIDsForClass:(Class)aClass;
 
 // get objects satisfying a single attribute
 - (NSArray*) retrieveEntityIDsForClass:(Class)aClass withValue:(id)value forAttribute:(NSString*)attributeName;
 
 // get objects satisfying an arbitrary predicate
 - (NSArray*) retrieveEntityIDsForClass:(Class)aClass withPredicate:(NSPredicate*)predicate;
 
 // get objects in a given order
 - (NSArray *) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
 - (NSArray *) retrieveEntitiesForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
 
 // get only object IDs in a given order
 - (NSArray*) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray*)sortDescriptors;
 
 // get single object satisfying a single attribute
 //	the query must NOT return multiple objects, or an error will be raised
 - (NSObject*) retrieveSingleEntityForClass:(Class)aClass withValue:(id)value forAttribute:(NSString*)attributeName;
 

 // get a full object from an ID
- (NSObject*) entityWithID:(id)ID;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@end
