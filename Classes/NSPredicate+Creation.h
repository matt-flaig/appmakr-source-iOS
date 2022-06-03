//
//  NSPredicate+Creation.h
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 5/24/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPredicate(Creation)

+ (NSPredicate*) predicateWithValue:(id)value forAttribute:(NSString*)attribute;

@end
