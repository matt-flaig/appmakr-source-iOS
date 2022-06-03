//
//  TiledImageView.m
//  appbuildr
//
//  Created by Fawad Haider  on 5/18/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "TiledImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TiledImageView

@synthesize image = image_;


- (void)dealloc {
    [image_ release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame andImageString:(NSString*)imageString{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.image = [UIImage imageNamed:imageString];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGImageRef image = CGImageRetain(image_.CGImage);
    
    CGRect imageRect;
    imageRect.origin = CGPointMake(0.0, 0.0);
    imageRect.size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    CGContextRef context = UIGraphicsGetCurrentContext();       
    CGContextClipToRect(context, CGRectMake(0.0, 0.0, rect.size.width, rect.size.height));      
    CGContextDrawTiledImage(context, imageRect, image);
    CGImageRelease(image);
}

@end
