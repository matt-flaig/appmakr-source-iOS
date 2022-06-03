//
//  AppMakrCommentsTableHeaderView.h
//  appbuildr
//
//  Created by Fawad Haider  on 1/13/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppMakrCommentsTableFooterView : UIView
{
	
    UIImageView * searchBarImageView;
    UIButton * addCommentButton;
}

@property (nonatomic, retain) IBOutlet UIImageView * searchBarImageView;
@property (nonatomic, retain) IBOutlet UIButton * addCommentButton;

@end
