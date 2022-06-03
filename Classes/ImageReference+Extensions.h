//
//  ImageReference+Extensions.h
//
//
//  Created by William M. Johnson on 10-28-2010.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import "ImageReference.h"


@interface ImageReference(Extensions)

- (NSURL*) URL;

- (UIImage*) ImageObject;
- (BOOL) saveImage:(UIImage*)image;
- (BOOL) deleteImage;


@end
