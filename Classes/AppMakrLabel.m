//
//  AppMakrLabel.m
//  appbuildr
//
//  Created by Fawad Haider  on 1/21/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "AppMakrLabel.h"
#import "UILabel-Additions.h" 

@implementation AppMakrLabel


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self applyBlurAndShadow];
    }
    return self;
}

- (void)awakeFromNib{
	[self applyBlurAndShadow];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
