//
//  AppMakrPinView.h
//  appbuildr
//
//  Created by Fawad Haider  on 4/11/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BasicMapAnnotationView.h"

@interface AppMakrPinView : BasicMapAnnotationView {
    id<MKAnnotation> annotation;
}
@property (nonatomic, retain) id<MKAnnotation> annotation;

@end
