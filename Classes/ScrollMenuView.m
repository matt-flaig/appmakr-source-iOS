/*
 * ScrollMenuView.m
 * appbuildr
 *
 * Created on 4/27/12.
 * 
 * Copyright (c) 2012 Socialize, Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ScrollMenuView.h"
#import <QuartzCore/QuartzCore.h>

#define kMenuItemsOffset 16

@implementation ScrollMenuView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    for(int i = 0; i < self.subviews.count; i++)
    {       
        UIButton* item = [self.subviews objectAtIndex:i];
        CGFloat xVal = i*(kMenuItemIconSize + kMenuItemsOffset);
        CGFloat yVal = self.frame.size.height/2 - kMenuItemIconSize;
        
        CGSize labelSize = [item.titleLabel.text sizeWithFont:item.titleLabel.font];
        [item setFrame:CGRectMake(xVal, yVal, kMenuItemIconSize, kMenuItemIconSize + labelSize.height)];
    }
    [self scrollViewDidScroll:self];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGSize contentSize = CGSizeMake((kMenuItemIconSize) * self.subviews.count + kMenuItemsOffset * (self.subviews.count - 1), self.frame.size.height );
    [self setContentSize: contentSize];
    self.contentInset = UIEdgeInsetsMake(0, 60, 0, 60);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    float start = scrollView.contentOffset.x;    
    float width = scrollView.frame.size.width;
    float end = start + width;  // change so it doesn't scoot views past the end
    
    float viewOffset, viewTop;
    
    int index = 0;
    
    for(UIButton *thisView in self.subviews)
    {
        viewTop = thisView.frame.origin.x + thisView.frame.size.width;
        
        if((viewTop > start) && (thisView.frame.origin.x < end)){ // our visible range
            viewOffset = thisView.frame.origin.x - start;
            
            CGRect tempFrame = thisView.frame;
            float radius = self.frame.size.height/2;
            tempFrame.origin.y = radius - sin((viewOffset / width) * 4) * self.frame.size.height/2;
//            thisView.layer.opacity = viewOffset/29;
            
            thisView.frame = tempFrame;
            index++;
        }
    }
}


@end
