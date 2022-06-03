//
//  ActivityTableViewCell.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "ActivityTableViewCell.h"


@implementation ActivityTableViewCell
@synthesize nameLabel;
@synthesize activityTextLabel;
@synthesize profileImageView;
@synthesize activityIcon;
@synthesize informationView;
@synthesize profileView;
@synthesize commentTextLabel;
@synthesize btnViewProfile;

/*
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
        return self;
    }
        
    return nil;
}
*/

- (void) dealloc
{
	[nameLabel release];
	[btnViewProfile release];
	[activityTextLabel release];
	[commentTextLabel release];
	[profileImageView release];
	[activityIcon release];
	[informationView release];
	[super dealloc];
}


@end
