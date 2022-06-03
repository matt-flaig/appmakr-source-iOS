//
//  ActivityTableViewCell.h
//  appbuildr
//
//  Created by Isaac Mosquera on 11/23/10.
//  Copyright 2010 pointabout. All rights reserved.
//


@interface ActivityTableViewCell : UITableViewCell {

	UILabel         *nameLabel;
	UILabel         *activityTextLabel;
	UILabel         *commentTextLabel;
	UIImageView     *profileImageView;
	UIView          *profileView;
	UIImageView     *activityIcon;
	
	UIView          *informationView;
	UIButton        *btnViewProfile;
}
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *activityTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentTextLabel;
@property (nonatomic, retain) IBOutlet UIImageView * profileImageView;
@property (nonatomic, retain) IBOutlet UIImageView * activityIcon;
@property (nonatomic, retain) IBOutlet UIView * informationView;
@property (nonatomic, retain) IBOutlet UIView * profileView;
@property (nonatomic, retain) IBOutlet UIButton * btnViewProfile;
@end
