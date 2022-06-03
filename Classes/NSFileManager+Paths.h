//
//  NSFileManager+Paths.h
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 5/25/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager(Paths)

// given a name/path relative to the resources folder, get the full path
- (NSString*) pathForResource:(NSString*)resourcePath;

// given a name/path relative to the documents / saved data folder, get the full path.
// ex /Library/Caches/dataName
- (NSString*) pathForAppData:(NSString*)dataPath;

@end
