//
//  SocializeStatsView.m
//  appbuildr
//
//  Created by Fawad Haider  on 12/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SocializeStatsView.h"
#import "Entry.h"
#import "FeedObjects.h"
#import "Statistics.h"
#import "NSNumber+Additions.h"
#import "AppMakrShape.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kICON_DIMENSIONS_WIDTH 20
#define kICON_DIMENSIONS_HEIGHT 20

#define kSTATS_HEIGHT 20
#define kHORIZONTAL_PADDING 10


@interface SocializeStatsView()
-(void)drawCountString:(NSString*)count withIconName:(NSString*)iconName 
			   atPoint:(CGPoint)atPoint withColor:(UIColor*)bgColor withContext:(CGContextRef)context;
-(void)updateViewCountViewsOrigins;
@end

@implementation SocializeStatsView
@synthesize viewsCountString;
@synthesize likesCountString;
@synthesize commentsCountSting;
@synthesize hasNewComment;
@synthesize hasBeenLiked;
@synthesize hasBeenViewed;

#define kDefaultCornerRadius        5.0

- (id)initWithFrame:(CGRect)frame withStatsAlignment:(StatsAlignment)alignment{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor clearColor];
		_countStringFont = [[UIFont boldSystemFontOfSize:14.0f] retain];
		_alignment = alignment;

		self.viewsCountString = @"- ";
		self.likesCountString = @"- ";
		self.commentsCountSting = @"- ";
		
		_drawBackViewShadows = YES;
		
		switch (_alignment) {
			case VerticalAligned:
				_viewesDrawPoint = CGPointMake(5, 6 + 40);
				_likesDrawPoint = CGPointMake(5, 3 + 20);
				_commentsDrawPoint = CGPointMake(5, 0);
				break;

			case HorizontalAligned:
				_viewesDrawPoint = CGPointMake(5, 0);
				_commentsDrawPoint = CGPointMake(5  + 80, 0);
				_likesDrawPoint = CGPointMake(5 + 5 + 80 + 80 , 0);
				break;
			default:
				break;
		}
    }
    return self;
}

-(void)updateViewCountViewsOrigins{
	CGSize viewsSize = [viewsCountString sizeWithFont:_countStringFont];
	CGSize commentsSize = [commentsCountSting sizeWithFont:_countStringFont];

	switch (_alignment) {
		case HorizontalAligned:
			_commentsDrawPoint = CGPointMake(_viewesDrawPoint.x + viewsSize.width + kICON_DIMENSIONS_WIDTH + 2 + kHORIZONTAL_PADDING, _commentsDrawPoint.y);
			_likesDrawPoint = CGPointMake(_commentsDrawPoint.x + commentsSize.width + kICON_DIMENSIONS_WIDTH + 2 + kHORIZONTAL_PADDING, _likesDrawPoint.y) ;
			break;

		case VerticalAligned:
			break;

		default:
			break;
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self updateViewCountViewsOrigins];
	[self  drawCountString:self.viewsCountString withIconName:@"socialize_resources/view-sm-icon.png" 
				   atPoint:_viewesDrawPoint withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	
	if (self.hasBeenLiked){
		[self  drawCountString:self.likesCountString withIconName:@"socialize_resources/like-sm-icon.png" 
					   atPoint:_likesDrawPoint withColor:UIColorFromRGB(0xd15252) withContext:context]; 
	}
	else {
		[self  drawCountString:self.likesCountString withIconName:@"socialize_resources/like-sm-icon.png" 
					   atPoint:_likesDrawPoint withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	}
	
	if (self.hasNewComment){
		[self  drawCountString:self.commentsCountSting withIconName:@"socialize_resources/comment-sm-icon.png" 
					   atPoint:_commentsDrawPoint withColor:UIColorFromRGB(0x4694c9) withContext:context]; 
	}
	else{
		[self  drawCountString:self.commentsCountSting withIconName:@"socialize_resources/comment-sm-icon.png" 
					   atPoint:_commentsDrawPoint withColor:[UIColorFromRGB(0x44515d) colorWithAlphaComponent:0.5] withContext:context]; 
	}
}

-(void)drawCountString:(NSString*)count withIconName:(NSString*)iconName 
			   atPoint:(CGPoint)atPoint withColor:(UIColor*)bgColor 
		   withContext:(CGContextRef)context{
	
	CGSize viewsStringSize = [count sizeWithFont:_countStringFont];
	CGContextSetStrokeColorWithColor(context, [bgColor CGColor] );
	CGContextSetFillColorWithColor(context, [bgColor CGColor]);
	
	[AppMakrShape drawRoundedRect:CGRectMake(atPoint.x, atPoint.y + 7, viewsStringSize.width + kICON_DIMENSIONS_WIDTH + 2 + 4, kSTATS_HEIGHT) withContext:context];
	[[UIImage imageNamed:iconName] drawInRect:CGRectMake(atPoint.x + 2, atPoint.y + 7, kICON_DIMENSIONS_WIDTH , kICON_DIMENSIONS_HEIGHT)];
	
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor] );
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	[count drawInRect:CGRectMake(kICON_DIMENSIONS_WIDTH + atPoint.x + 2, atPoint.y +  8, viewsStringSize.width, kSTATS_HEIGHT) withFont:_countStringFont];
}


- (void)dealloc {
	self.viewsCountString = nil;
	self.likesCountString = nil;
	self.commentsCountSting = nil;
    [super dealloc];
}


@end
