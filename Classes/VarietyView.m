//
//  VarietyView.m
//  appbuildr
//
//  Created by Brian Schwartz on 12/11/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "VarietyView.h"
#import "ImageReference+Extensions.h"


@implementation VarietyView

@synthesize entry, cellHeadlineColor, cellSummaryColor, paintBackground, isEditing, highlighted, frame;

- (id)initWithFrame:(CGRect)frame 
{
//    if (self = [super initWithFrame:frame]) 
	{
        buttonGradientImg = [UIImage imageNamed:@"variety_background.png"];
		paintBackground = YES;
		
	//	self.opaque = YES;
    }
    return self;
}

- (void)setHighlighted:(BOOL)lit 
{
	// If highlighted state changes, need to redisplay.
	if(highlighted != lit) 
		highlighted = lit;
}


#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
		green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

- (void)draw:(CGRect)rect 
{
	UIFont *dateFont = [UIFont systemFontOfSize:9];
	UIColor *dateColor;
	CGPoint point;
	float textWidth = rect.size.width - 40;
	float topMargin = 5.0f;
	float leftMargin = 5.0f;
	float editingMargin = 0.0f;
	float thumbnailTargetWidth;
	
	if(isEditing)
		editingMargin = 35.0f;
	
	[self setFrame:rect];
	
	// Get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
	
	// Choose font color based on highlighted state.
	if(self.highlighted) 
		dateColor = [UIColor whiteColor];
	else 
		dateColor = [UIColor lightGrayColor];
	
	if(paintBackground) {
		// Draw cell background
		/*
		point = CGPointMake(0,0);
		[buttonGradientImg drawAtPoint:point];
		point = CGPointMake(320,0);
		[buttonGradientImg drawAtPoint:point];
		*/
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(ctx, 0, rect.size.height);
        CGContextAddLineToPoint(ctx, 0, 0);
		
        CGContextSetFillColorWithColor(ctx, [UIColorFromRGB(0xdee7f0)  CGColor]);
        CGContextFillPath(ctx);
	}
	
	if(entry.thumbnailImage) {
		
		if([entry.type isEqualToString:@"twitterSearch"])
			thumbnailTargetWidth = 48.0f;
		else
			thumbnailTargetWidth = 68.0f;
		
		textWidth = textWidth - thumbnailTargetWidth - leftMargin;
		
		// Draw thumbnail
		UIImage * thumnailImage = (UIImage *) [entry.thumbnailImage ImageObject];
		point = CGPointMake(leftMargin + (thumbnailTargetWidth - thumnailImage.size.width)/2 + editingMargin, 2*topMargin+(thumbnailTargetWidth - thumnailImage.size.height)/2);
		[thumnailImage drawAtPoint:point];
		
		// drawing the white rectangle around it
        CGContextSetLineWidth(ctx, 4.0);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGRect rectangle = CGRectMake(point.x, point.y, thumbnailTargetWidth, thumnailImage.size.height);
        CGContextAddRect(ctx, rectangle);
        CGContextStrokePath(ctx);		

	} else {
		thumbnailTargetWidth = 0.0f;
		textWidth = textWidth - thumbnailTargetWidth - leftMargin - editingMargin;
	}
	
	// Draw
	if(entry.updated)  {
		[dateColor set];
		if(entry.thumbnailImage)
			point = CGPointMake(thumbnailTargetWidth + (2*leftMargin) + editingMargin, rect.size.height - 3*topMargin);
		else
			point = CGPointMake(thumbnailTargetWidth + (2*leftMargin) + editingMargin, rect.size.height - 3*topMargin);
		[entry.updated drawAtPoint:point forWidth:textWidth withFont:dateFont lineBreakMode:UILineBreakModeTailTruncation];
	}
	
	//  drawing the right side of the cell
	//	UIButton *ifViewedButton = [UIButton buttonWithType:UIButtonTypeCustom];

}

- (void)dealloc 
{
	[entry release];
	[cellHeadlineColor release];
	[super dealloc];
}

@end
