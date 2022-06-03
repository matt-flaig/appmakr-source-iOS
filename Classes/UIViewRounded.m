
#import "UIViewRounded.h"

@implementation UIViewRounded
- (void)drawRect:(CGRect)rect {
	
	int strokeWidth = 1;		
	float cornerRadius = 10.0;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextSetLineWidth(context, strokeWidth);
	CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
	
	CGRect rrect = self.bounds;
	
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
	
	CGContextRestoreGState(context);
	
}
@end
