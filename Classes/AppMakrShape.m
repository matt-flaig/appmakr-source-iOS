//
//  AppMakrShape.m
//  appbuildr
//
//  Created by Fawad Haider  on 5/10/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrShape.h"


@implementation AppMakrShape

#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        4.0

+(void)drawRoundedRect:(CGRect)rect withContext:(CGContextRef)context{
    
    CGRect rrect = rect;
	CGFloat cornerRadius = kDefaultCornerRadius;
    CGFloat radius = cornerRadius;
    CGFloat width = CGRectGetWidth(rrect);
    CGFloat height = CGRectGetHeight(rrect);
    
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    
	if (radius > height/2.0)
        radius = height/2.0;    
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
