//
//  LikesTableViewCell.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"
#import "AppMakrSocializeService.h"
#import "SocializeStatsView.h"
@interface LikesTableViewCell : UITableViewCell <AppMakrSocializeServiceDelegate> {
	IBOutlet UILabel		*titleLabel;
	IBOutlet UIImageView	*thumbnail;
	IBOutlet UIImageView	*backgroundImageView;
	SocializeStatsView		*statsView;
	AppMakrSocializeService		*theService;
	
	Entry					*entry;
}

@property (nonatomic, retain) Entry				   *entry;
@property (nonatomic, retain) SocializeStatsView   *statsView;
@property (nonatomic, retain) AppMakrSocializeService   *theService;
@property (nonatomic, retain) IBOutlet UILabel	   *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnail;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;

- (void)setupCellWithEntry:(Entry *)entry;
- (UIImage *)thumbnailForType:(NSString *)typeString;
- (UIImage *)photoThumbnail;
- (UIImage *)audioThumbnail;
- (UIImage *)videoThumbnail;
- (UIImage *)textThumbnail;
@end
