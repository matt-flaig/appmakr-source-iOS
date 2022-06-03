//
//  SendMessageView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SendingMessageView : UIView {

	UIActivityIndicatorView * indicatorView;
	UILabel * labelView;
}

@property (nonatomic, readonly) UILabel * labelView;

@end
