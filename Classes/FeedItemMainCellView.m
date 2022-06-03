//
//  FeedItemMainCellView.m
//  appbuildr
//
//  Created by Fawad Haider  on 12/15/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "FeedItemMainCellView.h"
#import "Statistics.h"
#import "ImageReference+Extensions.h"
#import "UIImage+Resize.h"
#import "AppMakrShape.h"

#define UIColorFromRGB(rgbValue) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    	green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define THUMBNAIL_WIDTH 65.0f

@interface FeedItemMainCellView()
-(void)drawThumbnailAndBackground:(CGRect)rect;
-(BOOL)shouldDrawThumbnail:(UIImage*)image;
-(void)drawWithIconName:(NSString*)iconName 
                atPoint:(CGPoint)atPoint withColor:(UIColor*)bgColor 
            withContext:(CGContextRef)context;
@end


@implementation FeedItemMainCellView

@synthesize headlineString;
@synthesize summaryString;
@synthesize updatedDate;
@synthesize highlighted;

- (id)initWithFrame:(CGRect)frame titleColor:(UIColor *)titleColor descColor:(UIColor *)descColor{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		_isHeadlineHidden = NO;
		paintBackground = YES;
		
		_dateFont = [[UIFont systemFontOfSize:8] retain];
		_summaryFont = [[UIFont systemFontOfSize:10] retain];
		_headlineFont = [[UIFont boldSystemFontOfSize:12] retain];
        
        _summaryColor = [descColor retain];
        _headlineColor = [titleColor retain];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		_isHeadlineHidden = NO;
		paintBackground = YES;
		
		_dateFont = [[UIFont systemFontOfSize:8] retain];
		_summaryFont = [[UIFont systemFontOfSize:10] retain];
		_headlineFont = [[UIFont boldSystemFontOfSize:12] retain];
        
        _summaryColor = [UIColor darkGrayColor];
        _headlineColor = [UIColor blackColor];
    }
    return self;
}

-(BOOL)shouldDrawThumbnail:(UIImage*)image{
    if ((image.size.width > 30) && (image.size.height > 30)){
        return YES;
    }
    return NO;
}


- (void) setupViewWithEntry:(Entry *)cellEntry withIndention:(BOOL)isEditing {
	
    isLiked = [cellEntry.liked boolValue];
//    hasNewComment = [cellEntry.statistics.hasNewComment boolValue];
    UIImage* mythumbnailImage = [cellEntry.thumbnailImage ImageObject];
    if( mythumbnailImage.size.width > THUMBNAIL_WIDTH || mythumbnailImage.size.height > THUMBNAIL_WIDTH ) {
        mythumbnailImage = [mythumbnailImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                              bounds:CGSizeMake( THUMBNAIL_WIDTH, THUMBNAIL_WIDTH)
                                                interpolationQuality:kCGInterpolationDefault];
        [cellEntry.thumbnailImage saveImage:mythumbnailImage];
    }
    
    if([cellEntry.type isEqualToString:@"twitterSearch"])
        thumbnailTargetWidth = 48.0f;
    else
        thumbnailTargetWidth = THUMBNAIL_WIDTH;
    
    self.updatedDate = cellEntry.updated;

    
    if (thumbnailImage){
        [thumbnailImage release];
    }
        
    thumbnailImage = [[cellEntry.thumbnailImage ImageObject] retain];
    
	_isEditing = isEditing;
	leftMargin = 5.0f;
	editingMargin = 0.0f;
	summaryTopMargin = 0.0f;
	
	if(isEditing)
		editingMargin = 35.0f;
	
	if([cellEntry.type isEqualToString:@"twitterSearch"])
		thumbnailTargetWidth = 48.0f;
	else
		thumbnailTargetWidth = 65.0f;
	
	//SETUP TITLE
	self.headlineString = cellEntry.title; 
	
	headlineSize = [headlineString sizeWithFont:_headlineFont constrainedToSize:CGSizeMake(self.frame.size.width - 40, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
    if ([self shouldDrawThumbnail:[cellEntry.thumbnailImage ImageObject]]) 
		headlineSize = [headlineString sizeWithFont:_headlineFont constrainedToSize:CGSizeMake(self.frame.size.width- 40 - thumbnailTargetWidth - 2*leftMargin, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
	
	if (headlineSize.height <= 25.0) {
		summaryTopMargin = 23.0f;
		summaryLabelHeight = 40.0f;
	}
	else {
		summaryTopMargin = 38.0f;
		summaryLabelHeight = 30.0f;
	}
	
	if (headlineSize.height > 38) 
		headlineLabelHeight = 38;
	else 
		headlineLabelHeight = headlineSize.height;
	
	if([cellEntry.type isEqualToString:@"twitterUserTimeline"]) {
		_isHeadlineHidden = YES;
		summaryLabelHeight = 50.0;
		summaryTopMargin = 5.0f;
	}
	
	_headlineFrame = CGRectMake(10.0 + editingMargin, 5.0, headlineSize.width, headlineLabelHeight);
	
	//CLEAN THE HTML ENTITIES OUT AND SETUP SUMMARY LABEL
	if(cellEntry.formattedDescription) {
		self.summaryString = cellEntry.formattedDescription;
		_summaryFrame = CGRectMake( 10 + editingMargin , summaryTopMargin, self.frame.size.width-40, summaryLabelHeight);
	}
	
	if([self shouldDrawThumbnail:[cellEntry.thumbnailImage ImageObject]]) {
		//IF THERE IS A THUMBNAIL WE NEED TO MOVE AND RESIZE THE LABELS TO A NEW PLACE TO MAKE ROOM!
		CGRect oldHeadlineFrame = _headlineFrame;
		_headlineFrame	= CGRectMake( (leftMargin*2) + thumbnailTargetWidth + editingMargin, oldHeadlineFrame.origin.y, self.frame.size.width-40 - thumbnailTargetWidth - leftMargin , oldHeadlineFrame.size.height );

		CGRect oldSummaryFrame = _summaryFrame;
		_summaryFrame = CGRectMake( (leftMargin*2) + thumbnailTargetWidth + editingMargin, oldSummaryFrame.origin.y, self.frame.size.width-40 - thumbnailTargetWidth - leftMargin, oldSummaryFrame.size.height);
	}
	
	[self setNeedsDisplay];
}

#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        4.0

#define kICON_DIMENSIONS_WIDTH 20
#define kICON_DIMENSIONS_HEIGHT 20
#define kSTATS_HEIGHT 20

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    // Drawing code.
    [super drawRect:rect];
	CGContextRef context = UIGraphicsGetCurrentContext();

	[self drawThumbnailAndBackground:rect];
	NSString* headlineText = headlineString;
	NSString* summaryText  = summaryString;	
	
	// drawing headline string
	if (!_isHeadlineHidden){
        if (highlighted){
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor] );
            CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        }
        else{
            CGContextSetStrokeColorWithColor(context, [_headlineColor CGColor] );
            CGContextSetFillColorWithColor(context, [_headlineColor CGColor]);
        }
            
		[headlineText drawInRect:_headlineFrame withFont:_headlineFont];
	}
	
	// drawing summary string
    if (highlighted){
        CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor] );
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    }
    else{
        CGContextSetStrokeColorWithColor(context, [_summaryColor CGColor] );
        CGContextSetFillColorWithColor(context, [_summaryColor CGColor]);
    }
	[summaryText drawInRect:_summaryFrame withFont:_summaryFont];
	
	CGContextStrokePath(context);		
    CGContextSetLineWidth(context, kDefaultStrokeWidth);
/*
    [self drawWithIconName:@"socialize_resources/view-sm-icon.png" 
				   atPoint:CGPointMake(300, 6 + 40) withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	
	if (isLiked){
		[self  drawWithIconName:@"socialize_resources/like-sm-icon.png" 
					   atPoint:CGPointMake(300, 3 + 20) withColor:UIColorFromRGB(0xd15252) withContext:context]; 
	}
	else {
		[self  drawWithIconName:@"socialize_resources/like-sm-icon.png" 
					   atPoint:CGPointMake(300, 3 + 20) withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	}
	
	if (hasNewComment){
		[self  drawWithIconName:@"socialize_resources/comment-sm-icon.png" 
					   atPoint:CGPointMake(300, 0) withColor:UIColorFromRGB(0x4694c9) withContext:context]; 
	}
	else{
		[self  drawWithIconName:@"socialize_resources/comment-sm-icon.png" 
					   atPoint:CGPointMake(300, 0) withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	}*/
}

#define kRightFrontSmallViewIconHeight				20
#define kRightFrontSmallViewIconHeightSpacing		3

-(void)drawWithIconName:(NSString*)iconName 
			   atPoint:(CGPoint)atPoint withColor:(UIColor*)bgColor 
		   withContext:(CGContextRef)context{
	
	CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
	CGContextSetFillColorWithColor(context, [bgColor CGColor]);
	
	[AppMakrShape drawRoundedRect:CGRectMake(atPoint.x, atPoint.y + 7, kICON_DIMENSIONS_WIDTH + 2 + 4, kSTATS_HEIGHT) withContext:context];
    
	[[UIImage imageNamed:iconName] drawInRect:CGRectMake(atPoint.x + 2, atPoint.y + 7, kICON_DIMENSIONS_WIDTH , kICON_DIMENSIONS_HEIGHT)];
}

//drawing the background text
- (void)drawThumbnailAndBackground:(CGRect)rect {
	
	UIColor *dateColor;
	CGPoint point;
	float	textWidth = rect.size.width - 40;
	float	topMargin = 3.5f;
	
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
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, 0);
        CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(ctx, 0, rect.size.height);
        CGContextAddLineToPoint(ctx, 0, 0);
        
		if (highlighted)
            CGContextSetFillColorWithColor(ctx, [[UIColor  blueColor]  CGColor]);
        else
            CGContextSetFillColorWithColor(ctx, [UIColorFromRGB(0xeeeeee)  CGColor]);
        CGContextFillPath(ctx);
	}
	
	
	if([self shouldDrawThumbnail:thumbnailImage]) {
		
		textWidth = textWidth - thumbnailTargetWidth - leftMargin;
		// Draw thumbnail
		UIImage * mythumnailImage = thumbnailImage;
		point = CGPointMake(leftMargin + (thumbnailTargetWidth - mythumnailImage.size.width)/2 + editingMargin, 2*topMargin+(thumbnailTargetWidth - mythumnailImage.size.height) / 2);
		[mythumnailImage drawAtPoint:point];
		
	} else {
		thumbnailTargetWidth = 0.0f;
		textWidth = textWidth - thumbnailTargetWidth - leftMargin - editingMargin;
	}
	

	if(self.updatedDate)  {
		
		[dateColor set];
		if([self shouldDrawThumbnail:thumbnailImage])
			point = CGPointMake(thumbnailTargetWidth + (2*leftMargin) + editingMargin, rect.size.height - 4*topMargin);
		else
			point = CGPointMake(thumbnailTargetWidth + (2*leftMargin) + editingMargin, rect.size.height - 4*topMargin);
		
		[self.updatedDate drawAtPoint:point forWidth:textWidth withFont:_dateFont lineBreakMode:UILineBreakModeTailTruncation];
	}
}

-(void)setSelected:(BOOL)selected{
	if (selected){
        highlighted = selected;
        [self setNeedsDisplay];
	}
}

-(void)prepareForReuse{
	_headlineFrame = CGRectZero;
	_summaryFrame = CGRectZero; 
}

-(void)setHighlighted:(BOOL)myhighlighted{
    highlighted = myhighlighted;
    [self setSelected:myhighlighted];
}

-(void)unHighlight{
	[self setSelected:NO];
	[self setHighlighted:NO];
}

- (void)dealloc {
    self.updatedDate = nil;
    [thumbnailImage release];
	self.headlineString = nil;
	self.summaryString = nil;
	[_dateFont release];
	[_summaryFont release];
	[_headlineFont release];
    [_summaryColor release];
    [_headlineColor release];
    [super dealloc];
}

@end

