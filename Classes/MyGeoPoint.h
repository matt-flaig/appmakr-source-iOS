//
//  MyGeoPoint.h
//  appbuildr
//
//  Created by Admin  on 4/8/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyGeoPoint : NSObject {
    
    NSNumber * lat;
    NSNumber * lng;
}

@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;

@end
