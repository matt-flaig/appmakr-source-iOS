//
//  LikesTableViewCell.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "LikesTableViewCell.h"
#import "FeedObjects.h"
#import "Statistics.h"
#import "Entry+Extensions.h"
#import "ModuleFactory.h"
#import "NSNumber+Additions.h"

#define kSocializeStatsViewRect CGRectMake(60, 26, 250, 30)
#define kDefaultCornerRadius   4.0

#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
		green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface LikesTableViewCell()
-(void)updateCounts:(Entry*)myentry;
@end

@implementation LikesTableViewCell

@synthesize titleLabel;
@synthesize thumbnail;
@synthesize theService;
@synthesize statsView;
@synthesize entry;
@synthesize backgroundImageView;

-(void)awakeFromNib{
	self.backgroundImageView.image = [[UIImage imageNamed:@"/socialize_resources/comments-cell-bg-borders.png"]  stretchableImageWithLeftCapWidth:0 topCapHeight:1];
}

- (void)setupCellWithEntry:(Entry *)myentry{

	self.entry = myentry;
	NSLog(@"entry.title = %@", myentry.title);
	self.titleLabel.text = myentry.title;
	
	DebugLog(@"Module type %@", myentry.moduleType);
	
	if ([myentry.moduleType isEqualToString:moduleTypeAlbum])
		thumbnail.image = [self thumbnailForType:@"photo"];
	else if ([myentry.moduleType isEqualToString:moduleTypeGeoRss])
		thumbnail.image = [self thumbnailForType:@"geo"];
	else if ([myentry.moduleType isEqualToString:moduleTypeRss])
		thumbnail.image = [self thumbnailForType:@"text"];
	else if ([myentry.moduleType isEqualToString:moduleTypeRss])
		thumbnail.image = [self thumbnailForType:@"text"];
	
	if (statsView == nil){
		statsView = [[SocializeStatsView alloc] initWithFrame:kSocializeStatsViewRect withStatsAlignment:HorizontalAligned];
		[self.contentView addSubview:statsView];
	}
	
	if (self.entry.statistics == nil){
		if (self.theService == nil)
			self.theService = [[AppMakrSocializeService alloc] init];
		
		self.theService.delegate = self;
		NSArray	* entryArray = [NSArray arrayWithObject:self.entry];
		[self.theService fetchStatisticsForEntries:entryArray]; 
	}
	else 
		[self updateCounts:self.entry];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchStatisticsForEntries:(NSArray	*)entries error:(NSError *)error{
	if (!error)
		[self updateCounts:self.entry];
}


-(void)updateCounts:(Entry*)myentry{
	
	if (myentry.statistics != nil) {
		
		statsView.viewsCountString =  [NSNumber formatMyNumber:myentry.statistics.numberOfViews ceiling:[NSNumber numberWithInt:100000]]  ;
		statsView.likesCountString = [NSNumber formatMyNumber:myentry.statistics.numberOfLikes ceiling:[NSNumber numberWithInt:100000]];
		statsView.commentsCountSting = [NSNumber formatMyNumber:myentry.statistics.numberOfComments ceiling:[NSNumber numberWithInt:100000]];
	
/*		if (myentry.lastViewDate)
			statsView.hasBeenViewed = YES;
		else 
			statsView.hasBeenViewed = NO;
		
		statsView.hasBeenLiked = [myentry.liked boolValue];
		
		if (myentry.lastViewDate && myentry.statistics.lastCommentDate){
			if ([myentry.lastViewDate compare:myentry.statistics.lastCommentDate] == NSOrderedAscending)
				statsView.hasNewComment = YES;
			else 
				statsView.hasNewComment = NO;
		}
		else if (myentry.statistics.lastCommentDate)
			statsView.hasNewComment = YES;
		else
			statsView.hasNewComment = NO;
*/		
		[statsView setNeedsDisplay];
	}
}

- (UIImage *)thumbnailForType:(NSString *)typeString{
	typeString = [typeString stringByAppendingString:@"Thumbnail"];
	SEL selector = NSSelectorFromString(typeString);
	if ([self respondsToSelector:selector]) {
		return [self performSelector:selector];
	}
	return nil;
}

- (UIImage *)photoThumbnail{
	
	UIImage *photoImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-photo.png"];
	return photoImage;
}

- (UIImage *)audioThumbnail{
//	!!!: TODO replace the image with the audio thumbnail
	UIImage *audioImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-audio.png"];
	return audioImage;
}

- (UIImage *)videoThumbnail{
//	!!!: TODO replace the image with the video thumbnail
	UIImage *videoImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-video.png"];
	return videoImage;
}

- (UIImage *)textThumbnail{
//	!!!: TODO replace the image with the text thumbnail	
	UIImage *textImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-article@2x.png"];
	return textImage;
}

- (UIImage *)rssThumbnail{
	//	!!!: TODO replace the image with the text thumbnail	
	UIImage *textImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-article.png"];
	return textImage;
}

- (UIImage *)geoThumbnail{
	UIImage *textImage = [UIImage imageNamed:@"socialize_resources/socialize-likes-type-icon-geo.png"];
	return textImage;
}

-(void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,CGSizeMake(55,55)}, [[UIImage imageNamed:@"/socialize_resources/comment-cell-bg-tile.png"] CGImage]);
}

-(void)dealloc{
	self.entry= nil;
	self.theService = nil;
	self.statsView = nil;
	self.titleLabel = nil;
	self.thumbnail = nil;
	[super dealloc];
}

@end
