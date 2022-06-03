//
//  CustomMessageToolBar.m
//  appbuildr
//
//  Created by Fawad Haider  on 10/29/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "CustomMessageToolBar.h"


@implementation CustomMessageToolBar


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)setFrame:(CGRect)rect {
	
	if (([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait)
		||([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)){
		
		[super setFrame:CGRectMake(216 - 40, -1, rect.size.width, 44)];
	}
	else {
		[super setFrame:CGRectMake(381 - 40, -1, rect.size.width, 32)];
	}
} 

- (void)dealloc {
    [super dealloc];
}


@end
