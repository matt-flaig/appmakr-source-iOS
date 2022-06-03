//
//  ProfileEditValueController.h
//  appbuildr
//
//  Created by William Johnson on 1/11/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditValueTableViewCell.h"

@interface ProfileEditValueController : UITableViewController <UITextFieldDelegate>
{

	EditValueTableViewCell * editValueCell;
	UITextField * editValueField;
	NSIndexPath * indexPath;
	NSString * valueToEdit;
	
	BOOL didEdit;
}
@property (nonatomic, assign) BOOL didEdit;
@property (nonatomic, assign) IBOutlet EditValueTableViewCell * editValueCell;
@property (nonatomic, assign) IBOutlet UITextField * editValueField;
@property (nonatomic, retain) NSIndexPath * indexPath;
@property (nonatomic, retain) NSString * valueToEdit;

@end
