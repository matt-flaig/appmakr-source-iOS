//
//  CaptionView.m
//  appbuildr
//
//  Created by Isaac Mosquera on 4/28/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "CaptionView.h"
#define PADDING 5.0f

@implementation CaptionView



- (void)dealloc {
	[titleLabel release];
	[descriptionLabel release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)aRect title:(NSString*)aTitle description:(NSString *)aDescription {
	if ((self = [super initWithFrame:aRect])) {
		self.backgroundColor = [UIColor clearColor];
		self.alpha = .5f;
			
		titleLabel = [[UILabel alloc] init];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.text = aTitle;
		titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		titleLabel.numberOfLines = 2;
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:titleLabel];
		
		descriptionLabel = [[UILabel alloc] init];		
		descriptionLabel.textColor = [UIColor whiteColor];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.numberOfLines = 0;
		descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		descriptionLabel.text = aDescription;
		
		descriptionLabel.font = [UIFont systemFontOfSize:13.0f];
//		CGRect newRect = [descriptionLabel textRectForBounds:descRect  limitedToNumberOfLines:0];
//		DebugLog(@"new rect is %f %f", newRect.size.width, newRect.size.height);
		
		[self addSubview:descriptionLabel];
	}
	return self;
}

-(void)layoutSubviews {

	CGSize descConstrainedSized = CGSizeMake(self.frame.size.width-PADDING, self.frame.size.height * .55);
	CGSize titleConstrainedSized = CGSizeMake(self.frame.size.width-PADDING, self.frame.size.height * .30);
	CGSize descriptionSize = [descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:descConstrainedSized lineBreakMode:UILineBreakModeWordWrap];
	CGSize titleSize = [titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:titleConstrainedSized];

	/* Fawad Haider NOTE: 
	   Changing 	
	 descriptionLabel.frame = CGRectMake( PADDING, descriptionLabelY,
										descriptionSize.width, descriptionSize.height );
	   To
	 descriptionLabel.frame = CGRectMake( PADDING, descriptionLabelY,
										descConstrainedSized.width, descriptionSize.height );
		
	 because on iOS 3.1.3 it returns incorrect width and we are really more concerned 
		with height as opposed to width
	 */
	float descriptionLabelY = self.frame.size.height - descriptionSize.height - PADDING;
	descriptionLabel.frame = CGRectMake( PADDING, descriptionLabelY,
											descConstrainedSized.width, descriptionSize.height );
	
	float titleLabelY = descriptionLabel.frame.origin.y - titleSize.height - PADDING;
	titleLabel.frame = CGRectMake( PADDING, titleLabelY, titleSize.width, titleSize.height);
}

@end
