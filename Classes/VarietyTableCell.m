//
//  VarietyTableCell.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/11/09.
//  Copyright 2009 PointAbout. All rights reserved.
//

#import "VarietyTableCell.h"
#import "FeedObjects.h"
#import "UIColor-Expanded.h"
#import "Statistics.h"

//#define TEMP_HARDCODED_VALUES	1

@interface VarietyTableCell()
@end


@implementation VarietyTableCell

@synthesize entry;
//@synthesize contentMoving;

- (id)initWithStyle:(UITableViewCellStyle)style titleColor:(UIColor *)titleColor descColor:(UIColor *)descColor  reuseIdentifier:(NSString *)reuseIdentifier
{ 
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {	
		
		mainView = [[FeedItemMainCellView alloc] initWithFrame:CGRectMake(0, 0, 320, 80) titleColor:titleColor descColor:descColor];
		self.contentView.frame = CGRectMake(0, 0, 320, 80);
		[self.contentView addSubview:mainView];
	}
	return self;
}


- (void) setupCellWithEntry:(Entry *)cellEntry withIndention:(BOOL)isEditing {
	self.entry = cellEntry;
	[mainView setupViewWithEntry:cellEntry withIndention:isEditing];
}

- (void)setHighlighted: (BOOL)highlighted animated: (BOOL)animated
{
    // don't highlight
    [super setHighlighted:highlighted animated:animated];
    [mainView setHighlighted:highlighted];
}

- (void)setSelected: (BOOL)selected animated: (BOOL)animated 
{
    // don't select
    [super setSelected:selected animated:animated];
    [mainView setHighlighted:selected];

}

-(void)unHighlight
{
	[self setSelected:NO];
	[self setHighlighted:NO];
}

- (void)prepareForReuse {
	self.entry = nil;
	[mainView prepareForReuse];
	[super prepareForReuse];
}


#pragma mark -
- (void)dealloc {
	[mainView release];
	[super dealloc];
}

@end
