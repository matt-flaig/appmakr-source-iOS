//
//  AMOperation.h
//  appbuildr
//
//  Created by Isaac Mosquera on 3/25/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _AppMakrOperationStatus {
    AMOperationStatusFailed = 0,
	AMOperationStatusSuccess = 1,
} AppMakrOperationStatus;

//the timeout is in seconds, not milliseconds
extern const int kAMOperationRetryTimeout;

@interface AppMakrOperation : NSOperation {
    AppMakrOperationStatus status;    
    NSString *objectID; //this is the objectId that this operation operates against.
}
@property(nonatomic,retain,readonly) NSString* objectID;
@property(nonatomic,assign,readonly) AppMakrOperationStatus status;
-(id) initWithUniqueID:(NSString *)uniqueObjectID;
@end
