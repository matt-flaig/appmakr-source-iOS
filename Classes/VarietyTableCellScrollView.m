//
//  VarietyTableCellScrollView.m
//  appbuildr
//
//  Created by Fawad Haider  on 11/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "VarietyTableCellScrollView.h"


@implementation VarietyTableCellScrollView
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*	
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
*/


- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
	
	if (!self.dragging) {
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	}		
	[super touchesEnded: touches withEvent: event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.dragging) {
		[self.nextResponder touchesBegan: touches withEvent:event]; 
	}		
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!self.dragging) {
		[self.nextResponder touchesMoved: touches withEvent:event]; 
	}		
	[super touchesMoved:touches withEvent:event];
}

- (void)dealloc {
    [super dealloc];
}

@end
