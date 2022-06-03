//
//  CoreDataRepository.m
//
//  Created by PointAbout Dev on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/**************************************************************
 This class performs the basic operations of create, retrieve, 
 update and delete mangedobjects.
 
 Save method is used to save all the operations performed.
 
 This class needs an instance of the mangedObjectContext to 
 perform these operations.
 **************************************************************/

#import "CoreDataRepository.h"
#import "NSError+Creation.h"


//#define LOGQUERIES 1
#define kCoreDataDatabaseFilename		@"MashupDataModel.sqlite"
#define kCoreDataDataModelName			@"MashupDataModel"

@interface CoreDataRepository ()
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)newManagedObjectModel;
@end

static NSPersistentStoreCoordinator * defaultCoordinator = nil;


static NSString * databasePath = nil;
static NSString * modelPath = nil;

@implementation CoreDataRepository

//#ifdef	UNIT_TESTS_LOGIC
//+ (void)initialize
//{
//	NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
//	modelPath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.mom"];
//	databasePath = [[currentBundle bundlePath] stringByAppendingPathComponent:@"MashupDataModel.sqlite"];
//	
//	NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
//	NSManagedObjectModel * managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
//	NSLog(@"============================================\nOBJECT MODEL PATH->%@", modelPath );
//	
//	NSURL * storeURL = [NSURL fileURLWithPath:databasePath];
//	
//	NSLog(@"\nSTORE URL PATH->%@\n============================================",storeURL);
//	
//	defaultCoordinator = [[CoreDataRepository persistentStoreCoordinatorWithManagedObjectModel:managedObjectModel] retain];
//	[managedObjectModel release];
//	
//	
//	
//}
//#else
+ (void)initialize
{
	
	if (!modelPath) 
	{
		modelPath = [[NSBundle mainBundle] pathForResource:kCoreDataDataModelName ofType:@"momd"];
			
	}
	
	if (!databasePath)
	{
		NSString* docs = [CoreDataRepository applicationCacheDirectory];
		databasePath = [docs stringByAppendingPathComponent:kCoreDataDatabaseFilename];
	}

	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	
	NSNumber * destroyCoreDataDatabase = [defaults objectForKey:@"destoryDB"];
	
	BOOL destroyDB = (destroyCoreDataDatabase !=nil)? [destroyCoreDataDatabase boolValue] : YES;
	
	if (destroyDB) 
	{
		[CoreDataRepository wipeout];
		[defaults setObject:[NSNumber numberWithBool:NO] forKey:@"destoryDB"];
	}

	
	
	NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
	NSManagedObjectModel * managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
   
	defaultCoordinator = [[CoreDataRepository persistentStoreCoordinatorWithManagedObjectModel:managedObjectModel] retain];
	[managedObjectModel release];
	
}
//#endif


- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		//[self managedObjectContext];
		managedObjectContext_ = nil;
		persistentStoreCoordinator_ = [defaultCoordinator retain];
		
		if (persistentStoreCoordinator_ != nil) 
		{
			managedObjectContext_ = [[NSManagedObjectContext alloc] init];
			[managedObjectContext_ setUndoManager:nil];
			[managedObjectContext_ setPersistentStoreCoordinator:persistentStoreCoordinator_];
		}
		
		
	}
	return self;
}

+ (void) wipeout
{
	//NSString* docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	//	NSString* dbPath = [docs stringByAppendingPathComponent:kCoreDataDatabaseFilename];
	NSError* error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
	if (error){
		DebugLog(@"Data Store error:%@ - %@",[error localizedFailureReason], [error localizedDescription]);
	}
}

// This method will add entities to the core data
- (NSObject *) createObjectOfClass:(Class)aClass
{	
	@try {
		NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:[aClass description] inManagedObjectContext:managedObjectContext_];
#if LOGQUERIES
		NSLog(@"*********** created entity: %@", entity);
#endif
		return entity;
	}
	@catch (NSException * e) 
	{
		DebugLog(@"Data Store error:%@",[e reason]);
		
	}
	@finally {
		
	}
	return nil;
}

// This method will delete entities from core data
- (void) deleteEntity:(NSManagedObject *)entity //withError:(NSError *)error 
{
#if LOGQUERIES
	NSLog(@"Deleting entity: %@", entity);
#endif
	[managedObjectContext_ deleteObject:entity];
	
}

- (void) deleteEntitiesForClass:(Class)aClass withPredicate:(NSPredicate *)predicate withError:(NSError **)error
{
	
	NSArray * results = nil; 
	results = [self retrieveEntityIDsForClass:aClass withSortDescriptors:nil
								 andPredicate:predicate error:error];
	
	if (results==nil || [results count]<=0) 
		return;
	
	
	for (NSManagedObjectID * objectIDToDelete in results) 
	{
		NSObject* objectToDelete = [self entityWithID:objectIDToDelete];
		[self deleteEntity:objectToDelete];
	}
	
}

// update the proeprties of entities in core data
- (void) updateEntity:(NSManagedObject *)entity forProperty:(id)property withValue:(id)value {
	[entity setValue:value forKey:property];
}

- (BOOL) save:(NSError **)error 
{
	BOOL saveResult;
    
	@try 
	{
        [managedObjectContext_ lock];
        if ([managedObjectContext_ hasChanges] == NO)
            saveResult = YES;
        else
        {
            [managedObjectContext_ processPendingChanges];
            saveResult = [managedObjectContext_ save:error];            
        }

		if (*error) 
		{
			DebugLog(@"Data Store error:Code %i :%@ - %@",[(*error) code],[(*error) localizedFailureReason], [(*error) localizedDescription]);
			NSArray* detailedErrors = [[*error userInfo] objectForKey:NSDetailedErrorsKey];
			//NSArray* detailedErrors = [[*error userInfo] objectForKey:@"conflictList"];
			
			
			int errorCount = [detailedErrors count];
			if(detailedErrors != nil && errorCount > 0) 
			{
				//for(NSError* detailedError in detailedErrors) 
//				{
//					DebugLog(@"  DetailedError: %@ - %@",[detailedError localizedRecoverySuggestion],[detailedError localizedDescription]);
//				}
				
				for(NSObject * error in detailedErrors)
				{
					DebugLog(@"  DetailedError: %@ ",error);	
				}
			}
			
			
		}
		
	}
	@catch (NSException * e) 
	{
		DebugLog(@"%@ - %@", [e name], [e reason]);
	}
	@finally 
	{
		[managedObjectContext_ unlock];
	}
	
	return saveResult;
}

- (NSArray *) retrieveEntitiesForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate 
								IDOnly:(BOOL)IDOnly error:(NSError **)error
{
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	if (IDOnly)
		request.resultType = NSManagedObjectIDResultType;
//#if LOGQUERIES
//	NSLog(@"Getting %@(s) with %@", [aClass description], predicate ? [predicate class] : @"(no restrictions)");
//#endif
	NSEntityDescription *entity = [NSEntityDescription entityForName:[aClass description] inManagedObjectContext:managedObjectContext_];
	if (entity == nil){
		if (error)
			*error = [NSError errorWithMessage:@"Attempted to fetch a class of invalid type '%@' from Core Data", [aClass description]]; 
		return nil;
	}
	[request setEntity:entity];
	
	if (sortDescriptors) {
		[request setSortDescriptors:sortDescriptors];
	}
	
	if (predicate) {
		[request setPredicate:predicate];
	}
	
	// NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext_ executeFetchRequest:request error:error];
	
	if (error != NULL && *error != nil) {
		DebugLog(@"Error getting %@(s) with %@: %@", [aClass description], predicate, *error);
		return nil;
	}
	else{
#if LOGQUERIES
		NSLog(@"\nResults for %@(s) with %@:\n%@", [aClass description], predicate, fetchResults);
#endif
		
		return fetchResults;
	}
	return nil;
}

- (NSArray *) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate 
								  error:(NSError **)error{
	return [self retrieveEntitiesForClass:aClass withSortDescriptors:sortDescriptors andPredicate:predicate
								   IDOnly:YES error:error];
}

- (NSArray *) retrieveEntitiesForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate 
								 error:(NSError **)error{
	return [self retrieveEntitiesForClass:aClass withSortDescriptors:sortDescriptors andPredicate:predicate
								   IDOnly:NO error:error];
}
- (NSObject*) entityWithID:(id)ID{
    
    if( [ID isKindOfClass:[NSManagedObjectID class]] ) {
        return [managedObjectContext_ existingObjectWithID:(NSManagedObjectID*)ID error:nil];
    } 
    if( [ID isKindOfClass:[NSURL class]] ) {
        NSManagedObjectID *mangedObjectID =[[managedObjectContext_ persistentStoreCoordinator] managedObjectIDForURIRepresentation:ID];
        return [managedObjectContext_ existingObjectWithID:mangedObjectID error:nil];
    }
    return nil;
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
		DebugLog(@" INITING THE CONTEXT %@", managedObjectContext_);
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


+ (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)newManagedObjectModel
{
	//Comment out for unit test until we can make this better.
	NSURL *storeURL = [NSURL fileURLWithPath:databasePath];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator * persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:newManagedObjectModel] autorelease];
    
    
    NSDictionary * migrationOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:migrationOptions error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }  
	
	return persistentStoreCoordinator;
	
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    
    if (persistentStoreCoordinator_ == nil) 
	{
		persistentStoreCoordinator_ =  [[CoreDataRepository persistentStoreCoordinatorWithManagedObjectModel:self.managedObjectModel] retain];
    }
	
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString *)applicationCacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -

- (void)saveContext 
{
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


-(void)dealloc
{
	[managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];	
	[super dealloc];
}



@end
