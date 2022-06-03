//
//  HPTextViewInternal.m
//  Cupido
//
//  Created by Hans Pinckaers on 30-06-10.
//  Copyright 2010 Hans Pinckaers. All rights reserved.
//

#import "HPTextViewInternal.h"


@implementation HPTextViewInternal

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
//		initiated by user...
//		self.contentInset = UIEdgeInsetsMake(-4, 0, -11, 0);
	} else {
//		self.contentInset = UIEdgeInsetsMake(-4, 0, -11, 0); //maybe use scrollRangeToVisible?
		if(s.y > self.frame.size.height - 5){
			//self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0); //maybe use scrollRangeToVisible?
		}
	}
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = UIEdgeInsetsMake(-2, 0, 2, 0);;
	//self.contentInset = UIEdgeInsetsMake(-4, 0, -4, 0); //maybe use scrollRangeToVisible?
	[super setContentInset:insets];
}

-(void)drawRect:(CGRect)rect{

	[super drawRect:rect];
    UIImage *img = [[UIImage imageNamed:@"searchbarbg.png"] stretchableImageWithLeftCapWidth:15.0 topCapHeight:15.0];
	[img drawInRect:rect];	
	
}


- (void)dealloc {
    [super dealloc];
}


@end
