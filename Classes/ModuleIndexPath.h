//
//  ModuleIndexPath.h
//  appbuildr
//
//  Created by Sergey Popenko on 2/6/12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModuleIndexPath : NSObject<NSCopying> {
}

@property(nonatomic, retain) NSNumber* moduleIndex;
@property(nonatomic, retain) NSNumber* childIndex;

+(ModuleIndexPath*) createWithIndex:(NSNumber*) mid childIndex: (NSNumber*)cid;

@end