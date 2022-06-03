//
//  AppMakrSocializeActionView.m
//  appbuildr
//
//  Created by Fawad Haider  on 12/9/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrSocializeActionView.h"
#import "FeedObjects.h"
#import "Statistics.h"
#import "SocializeStatsView.h"
#import "NSNumber+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "AppMakrShape.h"


#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
		green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppMakrSocializeActionView()

-(void)setupButtons;
-(void)addShadow:(UIView*)myview;
-(void)drawShadowedText:(NSString*)text 
				 inRect:(CGRect)rect withFont:(UIFont*)font 
			withContext:(CGContextRef)context
			  withColor:(UIColor*)fontColor;
-(void)addEntryObservers:(Entry*)myentry;
-(void)removeObserversForEntry:(Entry*)myentry;
-(void)updateCounts:(Entry*)myentry;
-(void)setButtonLabel:(NSString*)labelString 
		withImageForNormalState:(NSString*)bgImage 
		withImageForHightlightedState:(NSString*)bgHighlightedImage 
		withIconName:(NSString*)iconName
			 atOrigin:(CGPoint)frameOrigin 
			 onButton:(UIButton*)button
		withSelector:(SEL)selector;
-(CGSize)getButtonSizeForLabel:(NSString*)labelString iconName:(NSString*)iconName;
@end

@implementation AppMakrSocializeActionView

@synthesize likeButton;
@synthesize shareButton;
@synthesize commentButton;

- (id)initWithFrame:(CGRect)frame andActionDelegate:(id<AppMakrSocializeActionViewDelegate>)mydelegate andEntry:(Entry*)myentry{
    
    self = [super initWithFrame:frame];
    if (self) {
		_observersAdded = NO;
		self.entry = myentry;
		_buttonLabelFont = [[UIFont boldSystemFontOfSize:11.0f] retain];
		_shadowColor = [UIColor blackColor];
		_drawBackViewShadows = YES;
		
		socializeDelegate = mydelegate; 
		
		[self setupButtons];
	}
    return self;
}

-(Entry*)entry{
	return entry;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	
	if (object == entry && [keyPath isEqualToString:@"liked"]) {
		[self updateCounts:self.entry];
		[self setNeedsDisplay];
	}else if (object == entry.statistics && [keyPath isEqualToString:@"numberOfViews"]) {
		[self updateCounts:self.entry];
		[self setNeedsDisplay];
	} else if (object == entry.statistics && [keyPath isEqualToString:@"numberOfLikes"]){
		[self updateCounts:self.entry];
		[self setNeedsDisplay];
	} else if (object == entry.statistics && [keyPath isEqualToString:@"numberOfComments"]){
		[self updateCounts:self.entry];
		[self setNeedsDisplay];
	}
	else
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(void)addEntryObservers:(Entry*)myentry{
	if (myentry.statistics != nil && !_observersAdded){
		[myentry addObserver:self forKeyPath:@"liked" options:NSKeyValueObservingOptionNew context:NULL];
		[myentry.statistics addObserver:self forKeyPath:@"numberOfViews" options:NSKeyValueObservingOptionNew context:NULL];
		[myentry.statistics addObserver:self forKeyPath:@"numberOfLikes" options:NSKeyValueObservingOptionNew context:NULL];
		[myentry.statistics addObserver:self forKeyPath:@"numberOfComments" options:NSKeyValueObservingOptionNew context:NULL];
		_observersAdded = YES;
	}
 
}

-(void)removeObserversForEntry:(Entry*)myentry{
	// adding observers after 
	if (_observersAdded){
		if (myentry.statistics != nil){
			[myentry removeObserver:self forKeyPath:@"liked" ];
			[myentry.statistics removeObserver:self forKeyPath:@"numberOfViews" ];
			[myentry.statistics removeObserver:self forKeyPath:@"numberOfLikes" ];
			[myentry.statistics removeObserver:self forKeyPath:@"numberOfComments" ];
			_observersAdded = NO;
		}
	}
}

#define ACTION_VIEW_WIDTH 320
#define BUTTON_PADDINGS 4
#define ICON_WIDTH 16
#define ICON_HEIGHT 16
#define BUTTON_HEIGHT 30
#define BUTTON_Y_ORIGIN 7
#define PADDING_IN_BETWEEN_BUTTONS 10
#define COMMENT_INDICATOR_SIZE_WIDTH 17
#define COMMENT_INDICATOR_SIZE_HEIGHT 17
#define PADDING_BETWEEN_TEXT_ICON 2


-(void)updateCounts:(Entry*)myentry{
	
	if (myentry.statistics != nil) {
		
		[UIView beginAnimations:@"adjustActionBar" context:nil];

		CGPoint buttonOrigin;
		CGSize buttonSize;
		
		buttonSize = [self getButtonSizeForLabel:@"Share" iconName:@"socialize_resources/action-bar-icon-share.png"];
		buttonOrigin.x = ACTION_VIEW_WIDTH - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
		buttonOrigin.y = BUTTON_Y_ORIGIN;
		shareButton.frame = CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonSize.width, buttonSize.height);
		[shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -PADDING_BETWEEN_TEXT_ICON)]; // Left inset is the negative of image width.
		[shareButton setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		
		NSString* formattedValue = [NSNumber formatMyNumber:myentry.statistics.numberOfComments ceiling:[NSNumber numberWithInt:1000]];

		buttonSize = [self getButtonSizeForLabel:formattedValue  iconName:@"socialize_resources/comment-sm-icon.png"];
		buttonOrigin.x = buttonOrigin.x - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
		buttonOrigin.y = BUTTON_Y_ORIGIN;
		[commentButton setTitle:formattedValue forState:UIControlStateNormal] ;
		commentButton.frame = CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonSize.width, buttonSize.height);
		[commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -PADDING_BETWEEN_TEXT_ICON)]; // Left inset is the negative of image width.
		[commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0.0, 0.0)]; // Right inset is the negative of text bounds width.

		formattedValue = [NSNumber formatMyNumber:myentry.statistics.numberOfLikes ceiling:[NSNumber numberWithInt:1000]]; 

		buttonSize = [self getButtonSizeForLabel:formattedValue iconName:@"socialize_resources/likes-sm-icon.png"];
		buttonOrigin.x = buttonOrigin.x - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
		buttonOrigin.y = BUTTON_Y_ORIGIN;
		[likeButton setTitle:formattedValue forState:UIControlStateNormal] ;
		if ([[entry liked] boolValue]){
			[likeButton setBackgroundImage:[UIImage imageNamed:@"socialize_resources/action-bar-button-red.png"] forState:UIControlStateNormal]; 
			[likeButton setBackgroundImage:[UIImage imageNamed:@"socialize_resources/action-bar-button-red-hover.png"] forState:UIControlStateHighlighted]; 
			[likeButton setImage:[UIImage imageNamed:@"socialize_resources/action-bar-icon-liked.png"] forState:UIControlStateNormal];
			[likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		}
		else{
			[likeButton setBackgroundImage:[UIImage imageNamed:@"socialize_resources/action-bar-button-black.png"] forState:UIControlStateNormal]; 
			[likeButton setBackgroundImage:[UIImage imageNamed:@"socialize_resources/action-bar-button-black-hover.png"] forState:UIControlStateHighlighted]; 
			[likeButton setImage:[UIImage imageNamed:@"socialize_resources/action-bar-icon-like.png"] forState:UIControlStateNormal];
			[likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		}
		[likeButton setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		likeButton.frame = CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonSize.width, buttonSize.height);
		[likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -PADDING_BETWEEN_TEXT_ICON)]; // Left inset is the negative of image width.
		
		[_activityIndicator stopAnimating];
		[_activityIndicator removeFromSuperview];
		
		formattedValue = [NSNumber formatMyNumber:myentry.statistics.numberOfViews ceiling:[NSNumber numberWithInt:10000000]];

		buttonSize = [self getButtonSizeForLabel:formattedValue iconName:@"socialize_resources/view-sm-icon.png"];
		buttonOrigin.x = PADDING_IN_BETWEEN_BUTTONS; 
		buttonOrigin.y = BUTTON_Y_ORIGIN;

		[viewCounter setTitle:formattedValue forState:UIControlStateNormal];
		viewCounter.frame = CGRectMake(buttonOrigin.x, buttonOrigin.y, buttonSize.width, buttonSize.height);
		[viewCounter setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -PADDING_BETWEEN_TEXT_ICON - 2)]; // Left inset is the negative of image width.
		[viewCounter setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		viewCounter.hidden = NO;
		[UIView commitAnimations];
		
		
		if (_hasNewComment && !newCommentMarker){
			newCommentMarker = [[UIImageView alloc] initWithFrame:CGRectMake(commentButton.frame.size.width - (COMMENT_INDICATOR_SIZE_WIDTH/2) - 3,
																			 - (COMMENT_INDICATOR_SIZE_HEIGHT/2) + 3, 
																			 COMMENT_INDICATOR_SIZE_WIDTH, 
																			 COMMENT_INDICATOR_SIZE_HEIGHT )];
			newCommentMarker.image = [UIImage imageNamed:@"socialize_resources/action-bar-notification-icon.png"];
			newCommentMarker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			[commentButton addSubview:newCommentMarker];
			[commentButton bringSubviewToFront:newCommentMarker];
		}
	}
}

-(void)setEntry:(Entry *)cellEntry{
	
	if (entry != nil){
		[self removeObserversForEntry:entry];
		[entry release];
		
		entry = cellEntry;
		[entry retain];
		[self addEntryObservers:entry];
	}
	else {
		entry = cellEntry;
		[entry retain];
		[self addEntryObservers:entry];
	}
	if (entry != nil /*&& ![entry isFault]*/){
/*		if (entry.lastViewDate && entry.statistics.lastCommentDate){
			if ([entry.lastViewDate compare:entry.statistics.lastCommentDate] == NSOrderedAscending)
				_hasNewComment = YES;
			else 
				_hasNewComment = NO;
		}
		else if (entry.statistics.lastCommentDate)
			_hasNewComment = YES;
		else
			_hasNewComment = NO;
 */
        _hasNewComment = [entry.statistics.hasNewComment boolValue];
	}
	
	[self updateCounts:self.entry];
}

-(void)addShadow:(UIView*)myview{
    myview.layer.shadowColor = [[UIColor blackColor] CGColor];
    myview.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    myview.layer.shadowOpacity = 1.0f;
    myview.layer.shadowRadius = 5.0f;
}

-(void)setupButtons {

	CGPoint buttonOrigin;
	CGSize buttonSize;

	shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buttonSize = [self getButtonSizeForLabel:@"Share" iconName:@"socialize_resources/action-bar-icon-share.png"];
	buttonOrigin.x = ACTION_VIEW_WIDTH - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
	buttonOrigin.y = BUTTON_Y_ORIGIN;
	
	[self setButtonLabel:@"Share" 
			withImageForNormalState: @"socialize_resources/action-bar-button-black.png" 
			withImageForHightlightedState:@"socialize_resources/action-bar-button-black-hover.png"
			withIconName:@"socialize_resources/action-bar-icon-share.png"
			atOrigin:buttonOrigin
			onButton:shareButton
			withSelector:@selector(shareButtonPressed:)];
	[self addSubview:shareButton];
	
	commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buttonSize = [self getButtonSizeForLabel:nil iconName:@"socialize_resources/comment-sm-icon.png"];
	buttonOrigin.x = buttonOrigin.x - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
	buttonOrigin.y = BUTTON_Y_ORIGIN;
	
	[self setButtonLabel:nil 
			withImageForNormalState: @"socialize_resources/action-bar-button-black.png" 
			withImageForHightlightedState:@"socialize_resources/action-bar-button-black-hover.png"
			withIconName:@"socialize_resources/action-bar-icon-comments.png"
				atOrigin:buttonOrigin
				onButton:commentButton
			withSelector:@selector(commentButtonPressed:)];
	
		if (_hasNewComment){
			newCommentMarker = [[UIImageView alloc] initWithFrame:CGRectMake(commentButton.frame.size.width - (COMMENT_INDICATOR_SIZE_WIDTH/2) - 3,
																						 - (COMMENT_INDICATOR_SIZE_HEIGHT/2) + 3, 
																			COMMENT_INDICATOR_SIZE_WIDTH, 
																			COMMENT_INDICATOR_SIZE_HEIGHT )];
			newCommentMarker.image = [UIImage imageNamed:@"socialize_resources/action-bar-notification-icon.png"];
			newCommentMarker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			[commentButton addSubview:newCommentMarker];
			[commentButton bringSubviewToFront:newCommentMarker];
		}
	[self addSubview:commentButton];

	likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buttonSize = [self getButtonSizeForLabel:nil iconName:@"socialize_resources/action-bar-icon-like.png"];
	buttonOrigin.x = buttonOrigin.x - buttonSize.width - PADDING_IN_BETWEEN_BUTTONS; 
	buttonOrigin.y = BUTTON_Y_ORIGIN; 
	
	if ([[entry liked] boolValue]){
		[self setButtonLabel:nil 
			withImageForNormalState: @"socialize_resources/action-bar-button-red.png" 
				withImageForHightlightedState:@"socialize_resources/action-bar-button-red-hover.png"
				withIconName:@"socialize_resources/action-bar-icon-liked.png"
					atOrigin:buttonOrigin
					onButton:likeButton
				withSelector:@selector(likeButtonPressed:)];
	}
	else {
		[self setButtonLabel:nil 
			withImageForNormalState: @"socialize_resources/action-bar-button-black.png" 
			withImageForHightlightedState:@"socialize_resources/action-bar-button-black-hover.png"
				withIconName:@"socialize_resources/action-bar-icon-like.png"
					atOrigin:buttonOrigin
					onButton:likeButton
				withSelector:@selector(likeButtonPressed:)];
	}

	[self addSubview:likeButton];
 	viewCounter = [UIButton buttonWithType:UIButtonTypeCustom];
	viewCounter.userInteractionEnabled = NO;
	viewCounter.hidden = YES;

	buttonSize = [self getButtonSizeForLabel:nil iconName:@"socialize_resources/action-bar-icon-like.png"];
	buttonOrigin.x = PADDING_IN_BETWEEN_BUTTONS; 
	buttonOrigin.y = BUTTON_Y_ORIGIN;
	[self setButtonLabel:nil 
		withImageForNormalState: nil 
		withImageForHightlightedState:nil
			withIconName:@"socialize_resources/action-bar-icon-views.png"
				atOrigin:buttonOrigin
				onButton:viewCounter
			withSelector:nil];
	[self addSubview:viewCounter];
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(buttonOrigin.x, buttonOrigin.y + 5, 20, 20)];
	[self addSubview:_activityIndicator];
	[_activityIndicator startAnimating];
}

-(CGSize)getButtonSizeForLabel:(NSString*)labelString iconName:(NSString*)iconName {
	
	CGSize labelSize;
	if ([labelString length] <= 0)
	{
		labelSize = CGSizeZero;
	}
	
	labelSize = [labelString sizeWithFont:_buttonLabelFont];
	if (iconName)
		labelSize = CGSizeMake(labelSize.width + (2 * BUTTON_PADDINGS) + PADDING_BETWEEN_TEXT_ICON + 5 + ICON_WIDTH, BUTTON_HEIGHT);
	else
		labelSize = CGSizeMake(labelSize.width + (2 * BUTTON_PADDINGS), BUTTON_HEIGHT);
	
	return labelSize;
}

-(void)errorLoadingStats{
	[_activityIndicator stopAnimating];
	[_activityIndicator removeFromSuperview];
}

-(void)setButtonLabel:(NSString*)labelString 
		withImageForNormalState:(NSString*)bgImage 
		withImageForHightlightedState:(NSString*)bgHighlightedImage 
		withIconName:(NSString*)iconName
			 atOrigin:(CGPoint)frameOrigin 
			 onButton:(UIButton*)button
		 withSelector:(SEL)selector {
	
	CGSize buttonSize = [self getButtonSizeForLabel:labelString iconName:iconName];

	if (iconName)
		button.frame =  CGRectMake(frameOrigin.x, frameOrigin.y , buttonSize.width , buttonSize.height);
	else
		button.frame =  CGRectMake(frameOrigin.x, frameOrigin.y , buttonSize.width , buttonSize.height);
	
	UIImage* imageForNormalState = [[UIImage imageNamed:bgImage] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
	UIImage* imageForHighlightedState = [[UIImage imageNamed:bgHighlightedImage] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
	
	[button setBackgroundImage:imageForNormalState forState:UIControlStateNormal]; 
	[button setBackgroundImage:imageForHighlightedState forState:UIControlStateHighlighted]; 
	[button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
	
	// Now load the image and create the image view
	if (iconName){
		UIImage *image = [UIImage imageNamed:iconName];
		[button setImage:image forState:UIControlStateNormal];
		[button setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
	}
	
	// Create the label and set its text
	[button.titleLabel setFont:_buttonLabelFont];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.shadowColor = [UIColor blackColor]; 
	button.titleLabel.shadowOffset = CGSizeMake(0, -1); 
	[button setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
	if (labelString){
		[button setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0.0, 0.0)]; // Right inset is the negative of text bounds width.
		[button setTitle:labelString forState:UIControlStateNormal];
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -PADDING_BETWEEN_TEXT_ICON)]; // Left inset is the negative of image width.
	}
	else 
		[button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0)]; // Left inset is the negative of image width.
}

#pragma mark Socialize Delegate

-(void)commentButtonPressed:(id)sender{
	// Create the modal view controller
	newCommentMarker.hidden = YES;
	[socializeDelegate commentButtonTouched:self.entry];
}	

-(void)likeButtonPressed:(id)sender{
	[socializeDelegate likeButtonTouched:self.entry];
}

-(void)shareButtonPressed:(id)sender{
	[socializeDelegate shareButtonTouched:self.entry];
}

#pragma -
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
 // Drawing code.
}
*/


#define kBackViewLeftRect		 CGRectMake(0, 0, 110, self.bounds.size.height)
#define kBackViewViewNoRect	     CGRectMake(0, 0, 110, self.bounds.size.height)
#define kBackViewLikeNoRect	     CGRectMake(0, 0, 110, self.bounds.size.height)
#define kBackViewCommentNoRect	 CGRectMake(0, 0, 110, self.bounds.size.height)

#define kRightFrontSmallViewIconHeight				20
#define kRightFrontSmallViewIconHeightSpacing		3

-(void)drawShadowedText:(NSString*)text  
				 inRect:(CGRect)rect 
			   withFont:(UIFont*)font 
			withContext:(CGContextRef)context
			  withColor:(UIColor*)fontColor{
	
	CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	[text drawInRect:CGRectMake(rect.origin.x + 1, rect.origin.y + 2, 
								rect.size.width, rect.size.height) withFont:font];
	
	CGContextSetStrokeColorWithColor(context, [fontColor CGColor]);
	CGContextSetFillColorWithColor(context, [fontColor CGColor]);
	[text drawInRect:rect withFont:font];
}

- (void)drawRect:(CGRect)rect {
	
	[super drawRect:rect];
	[[[UIImage imageNamed:@"socialize_resources/action-bar-bg.png"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:0.5] 
			drawInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
					blendMode:kCGBlendModeMultiply alpha:1.0];
}

- (void)setSocializeDelegate:(id)delegate{
	socializeDelegate = delegate;
}

- (void)dealloc {
    DebugLog(@"Beginning deallocating SocializeActionPane");
	[_activityIndicator release];
	[self removeObserversForEntry:entry];
	[_shadowColor release];
    self.entry = nil;
	[_buttonLabelFont release];
    DebugLog(@"Ending deallocating SocializeActionPane");
	[super dealloc];
}
@end
