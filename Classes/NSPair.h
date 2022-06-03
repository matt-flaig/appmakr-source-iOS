//
//  NSPair.h
//  appbuildr
//
//  Created by Mac on 19.03.12.
//  Copyright (c) 2012 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPair : NSObject
{
    id first;
    id second;
}
@property (nonatomic, retain) id first;
@property (nonatomic, retain) id second;
@end