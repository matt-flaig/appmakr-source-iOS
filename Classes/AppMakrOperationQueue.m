//
//  AppMakrSyncDatabase.m
//  appbuildr
//
//  Created by Isaac Mosquera on 3/21/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrOperationQueue.h"
#import "AppMakrOperation.h"
#import "NetworkReadyOperation.h"
#import <objc/runtime.h>
AppMakrOperationQueue *_sharedOperationQueue;

NSString *persistedOpsFilename = @"persisted_operations.txt";
NSString *persistedOpsPath;

@interface AppMakrOperationQueue()
- (void)persistOperations;
- (AppMakrOperation *)createOperation:(NSString *)className withObjectId:(id)objectID;
@end

@implementation AppMakrOperationQueue

-(void)dealloc {
    [super dealloc];
}

+(void) initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    persistedOpsPath = [[paths lastObject] stringByAppendingPathComponent:persistedOpsFilename];
    persistedOpsPath = [persistedOpsPath retain];
}
+(AppMakrOperationQueue*)sharedOperationQueue
{
	@synchronized([AppMakrOperationQueue class])
	{
		if (!_sharedOperationQueue)
			[[self alloc] init];
		return _sharedOperationQueue;
	}
    
	return nil;
}

+(id)alloc
{
	@synchronized([AppMakrOperationQueue class])
	{
		NSAssert(_sharedOperationQueue == nil, @"Attempted to allocate a second instance of a appmakr jobmanager.");
        _sharedOperationQueue = [super alloc];
		return _sharedOperationQueue;
	}
    
	return nil;
}

-(id)init {
	self = [super init];
	if (self != nil) {
        [self addObserver:self forKeyPath:@"operations" options:0 context:NULL];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if( [defaultManager fileExistsAtPath:persistedOpsPath] ) {
            NSArray *operations = [[NSArray alloc]initWithContentsOfFile:persistedOpsPath];
            for (NSDictionary *operationDict in operations ) {
                NSString *className = (NSString *)[operationDict objectForKey:@"class"];
                NSString *objectID = (NSString *)[operationDict objectForKey:@"objectId"];
                AppMakrOperation *appmakrOperation = (AppMakrOperation *)[[NSClassFromString(className) alloc] initWithUniqueID:(id)objectID];
                [self setMaxConcurrentOperationCount:1];
                [self addOperation:appmakrOperation];
            }
            [operations release]; 
        }
	}
	return self;
}
- (AppMakrOperation *)createOperation:(NSString *)className withObjectId:(id)objectID {
    AppMakrOperation *appmakrOperation = (AppMakrOperation *)[[NSClassFromString(className) alloc] initWithUniqueID:(id)objectID];
    return appmakrOperation;
}
- (void)persistOperations {
    NSMutableArray *allOperations = [[NSMutableArray alloc]init];    
    @synchronized( [AppMakrOperationQueue class] ) {
        for(NSOperation *operation in [self operations]) {
            //only persist appmakr operations.  we dont want to persist the network check operation
            if( [operation isKindOfClass:[AppMakrOperation class]] ) {
                AppMakrOperation *appmakrOperation = (AppMakrOperation *)operation;
                NSDictionary *jobDict = [NSDictionary dictionaryWithObjectsAndKeys: 
                                         NSStringFromClass([appmakrOperation class]), @"class", 
                                         appmakrOperation.objectID, @"objectId",nil];
                [allOperations addObject:jobDict];
            }
        }
    }
    [allOperations writeToFile:persistedOpsPath atomically:YES];   
    [allOperations release];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context {
       if (object == self && [keyPath isEqualToString:@"operations"]) {
           [self persistOperations];
       }
}
- (void)addOperation:(AppMakrOperation *)operation {
    DebugLog(@"adding operation, of class %@, NS_BLOCKS_AVAILABLE -> %d", [[operation class] description], NS_BLOCKS_AVAILABLE);
    //this is syncronized so you can't add an operation while the fast enumeration is happening
    //to get the operations to persist to disk.
    @synchronized( [AppMakrOperationQueue class] ) {
        for(NSOperation* dependency in operation.dependencies ) {
            [super addOperation:dependency];
        }
        /*
        BOOL isReachable = NO;
        if ([operation respondsToSelector:@selector(setCompletionBlock:)]) {
            isReachable = YES;
        }
        
        void (^storedBlock)(void);
        storedBlock = Block_copy(^{
            if( operation.status == AMOperationStatusFailed ) {
                //NSLog(@"Inside a block");
                AppMakrOperation *newOperation = [self createOperation:NSStringFromClass([operation class])
                                                          withObjectId:operation.objectID];
                [self addOperation:newOperation];
            }
        });
        [storedBlock retain];
        [operation setCompletionBlock:storedBlock];
        */
        [operation setCompletionBlock: 
            ^{
                if( operation.status == AMOperationStatusFailed ) {
                    //NSLog(@"Inside a block");
                    AppMakrOperation *newOperation = [self createOperation:NSStringFromClass([operation class])
                                                         withObjectId:operation.objectID];
                    [self addOperation:newOperation];
                }
            }
        ];
        [super addOperation:operation];
    }
}

@end
