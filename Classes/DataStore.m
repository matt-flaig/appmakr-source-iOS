//
//  Storage.m
//  CoreData
//
//  Created by Rolf Hendriks on 4/5/10.
//  Modified by William Johnson on 10/21/2010
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataStore.h"
#import "CoreDataRepository.h"
#import "NSPredicate+Creation.h"



@implementation DataStore

//static id<ObjectRepositoryProtocol> s_repository = nil;
static DataStore * defaultDataStore = nil;

+ (void)initialize
{
	[DataStore initializeDataStore];
}

+ (void) initializeDataStore  //Kept for backwards compatability.
{	
	@synchronized (self)
	{		
		if(defaultDataStore == nil)
		{
		  defaultDataStore = [DataStore new];
		}
	}
	
}

+ (void) shutdown
{	
	
	@synchronized (self)
	{		
		
		[defaultDataStore save];
		[defaultDataStore release];
		defaultDataStore = nil;
	}
	
}
+ (DataStore *) defaultStore
{
	return defaultDataStore;
}
#pragma mark -
#pragma mark instance methods

- (void) dealloc
{
	[s_repository release];
	[super dealloc];
}


- (id) init
{
	self = [super init];
	if (self != nil) 
	{
	  s_repository = [CoreDataRepository new];

	}
	return self;
}





#pragma mark -
// add/remove entities
- (void) deleteEntities:(NSSet *)entitiesToDelete
{
	for(NSManagedObject * entity in entitiesToDelete) 
	{
		[self deleteEntity:entity];
	}
}

- (void) deleteEntity:(NSManagedObject *)entity
{
	[s_repository deleteEntity:entity];
}

// wipe out everything!
//	should be done before data store is accessed 1st time
//- (void) wipeout{
//	NSString* docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//	NSString* dbPath = [docs stringByAppendingPathComponent:kTDSCoreDataDatabase];
//	NSError* error = nil;
//	[[NSFileManager defaultManager] removeItemAtPath:dbPath error:&error];
//	if (error){
//		HandleErrorWithMessage(error, @"Failed to delete database");
//	}
//}

- (void) wipeout
{
	[CoreDataRepository wipeout];
}



- (void) lock{
	[((CoreDataRepository*)s_repository).managedObjectContext retain];
	[((CoreDataRepository*)s_repository).managedObjectContext lock];
}

- (void) unlock{
	[((CoreDataRepository*)s_repository).managedObjectContext unlock];	
	[((CoreDataRepository*)s_repository).managedObjectContext release];	
}

// createEntityOfType:
//	used to initially create an instance of an entity / managed object to put into the database
//	result type is the class CoreData automatically constructs from the object model
//	need to save changes for the object creation to be committed to the database.
//		input: name of table / entity to create
//		output: an instance of the class representing the given entity / table
- (NSObject*) createObjectOfClass:(Class)aClass{
	return [s_repository createObjectOfClass:aClass];
}

// saveChanges:
//	commits all changes made to the database since last time (insertions, deletes, updates)
- (BOOL) save
{
	NSError* error = nil;
	return [self save:&error];
}

- (BOOL)save:(NSError **)error
{
	return [s_repository save:error];
}

- (void) refreshEntity:(NSManagedObject*)object{
	[((CoreDataRepository*)s_repository).managedObjectContext refreshObject:object mergeChanges:NO];
}



// general reusable queries

// get all objects of a given type

- (NSArray*) retrieveEntityIDsForClass:(Class)aClass{
	return [self retrieveEntityIDsForClass:aClass withSortDescriptors:nil andPredicate:nil];
}

// get objects satisfying a single attribute
- (NSArray*) retrieveEntityIDsForClass:(Class)aClass withValue:(id)value forAttribute:(NSString*)attributeName{
	NSPredicate* predicate = [NSPredicate predicateWithValue:value forAttribute:attributeName]; 	
	NSArray* result = [self retrieveEntityIDsForClass:aClass withSortDescriptors:nil andPredicate:predicate];
	return result;
}

// get single object satisfying a single attribute
- (NSObject*) retrieveSingleEntityForClass:(Class)aClass withValue:(id)value forAttribute:(NSString*)attributeName{
	NSArray* results = [self retrieveEntityIDsForClass:aClass withValue:value forAttribute:attributeName];
	if (results.count > 1)
	{
		DebugLog(@"Found %d %s entities with the same %@ (%@)", results.count, object_getClassName(aClass), attributeName, value);
		return nil;
	}
	return results.count ? [self entityWithID:[results objectAtIndex:0]] : nil;
}


// get objects satisfying a predicate
- (NSArray*) retrieveEntityIDsForClass:(Class)aClass withPredicate:(NSPredicate*)predicate{
	return [self retrieveEntityIDsForClass:aClass withSortDescriptors:nil andPredicate:predicate];
}

- (NSArray *) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors{
	return [self retrieveEntityIDsForClass:aClass withSortDescriptors:sortDescriptors andPredicate:nil];
}

// get objects in a given order
- (NSArray *) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate{
	NSError* error = nil;
	NSArray* result = [s_repository retrieveEntityIDsForClass:aClass withSortDescriptors:sortDescriptors andPredicate:predicate error:&error];
	if (error){
		NSMutableString* message = [[NSMutableString alloc] initWithFormat:@"Error getting %s", object_getClassName(aClass)];
		if (predicate)
			[message appendFormat:@" satisfying conditions '%@'", predicate];
		NSLog(@"Data Store error:%@ - %@",[error localizedFailureReason], [error localizedDescription]);
		[message release];
		return nil;
	}
	
	return result;
}

- (NSArray *) retrieveEntitiesForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate{
	NSError* error = nil;
	NSArray* result = [s_repository retrieveEntitiesForClass:aClass withSortDescriptors:sortDescriptors andPredicate:predicate error:&error];
	if (error){
		NSMutableString* message = [[NSMutableString alloc] initWithFormat:@"Error getting %s", object_getClassName(aClass)];
		if (predicate)
			[message appendFormat:@" satisfying conditions '%@'", predicate];
		NSLog(@"Data Store error:%@ - %@",[error localizedFailureReason], [error localizedDescription]);
		[message release];
		return nil;
	}
	
	return result;
}

- (NSObject*) entityWithID:(id)ID{
	return [s_repository entityWithID:ID];
}

-(NSManagedObjectContext*) managedObjectContext
{
    return ((CoreDataRepository*)s_repository).managedObjectContext;
}
@end
