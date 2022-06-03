//
//  NSFileManager+Metadata.h
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 6/3/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager(Metadata)

- (NSDate*) lastModifiedDateForPath:(NSString*)filePath error:(NSError**)error;

@end
