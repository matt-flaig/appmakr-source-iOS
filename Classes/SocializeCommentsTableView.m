//
//  SocializeCommentsTableView.m
//  appbuildr
//
//  Created by Fawad Haider  on 1/25/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "SocializeCommentsTableView.h"


@implementation SocializeCommentsTableView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


-(void)awakeFromNib{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	[super touchesBegan:touches withEvent:event];
	[self.nextResponder touchesBegan:touches withEvent:event];
}


- (void)dealloc {
    [super dealloc];
}


@end
