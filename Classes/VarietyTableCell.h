//
//  VarietyTableCell.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/11/09.
//  Copyright 2009 PointAbout. All rights reserved.
//

#import "Entry.h"
#import "VarietyTableCellScrollView.h"
#import "FeedItemMainCellView.h"
//#import "SocializeOptionsView.h"

@interface VarietyTableCell : UITableViewCell/*<UIScrollViewDelegate>*/
{
	FeedItemMainCellView	*mainView;
	Entry					*entry;
}

@property (nonatomic, retain) Entry		*entry;

- (id)initWithStyle:(UITableViewCellStyle)style titleColor:(UIColor *)titleColor descColor:(UIColor *)descColor reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setupCellWithEntry:(Entry *)cellEntry withIndention:(BOOL)isEditing;
@end
