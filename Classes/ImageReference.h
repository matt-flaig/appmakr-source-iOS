//
//  ImageReference.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import "Entry.h"

@interface ImageReference :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * URLString;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Entry * entry;

@end



