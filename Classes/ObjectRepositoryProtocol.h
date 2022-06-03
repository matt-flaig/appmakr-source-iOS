//
//  ObjectRepository.h
//  Disney
//
//  Created by William M. Johnson on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectRepositoryProtocol <NSObject>
@optional

//NOTE:  Typically the Factory design pattern would be responsible for creating
//Objects.  However,  I wanted to provided one interface for managing the object
//life cycle(CRUD).  We should have multiple types of factories for a particular 
//persistent store,  but let's just keep it simple.  The implementation of this 
//protocol in a specific repository should know how to 
//create an object for a particular backing store.  
- (NSObject *) createObjectOfClass:(Class)aClass;
- (void) deleteEntity:(NSObject *)entity;
- (void) deleteEntitiesForClass:(Class)aClass withPredicate:(NSPredicate *)predicate withError:(NSError **)error;

- (void) updateEntity:(NSObject *)entity forProperty:(id)property withValue:(id)value;
- (BOOL) save:(NSError **)error;
- (NSArray *) retrieveEntityIDsForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate 
		      error:(NSError **)error;
- (NSObject*) entityWithID:(id)ID;
- (NSArray *) retrieveEntitiesForClass:(Class)aClass withSortDescriptors:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate 
								  error:(NSError **)error;



@end


