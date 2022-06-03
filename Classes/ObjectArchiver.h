//
//  Archiver.h
//  appbuildr
//
//  Created by Isaac Mosquera on 5/5/10.
//  Copyright 2010 pointabout. All rights reserved.
//

@interface ObjectArchiver : NSObject {
	NSObject * object;
}

- (id) initWithObject:(NSObject *)theObject name:(NSString *)name;
+ (void) removeAllArchivedData;
@end
