/*
 * HeaderImage.m
 * appbuildr
 *
 * Created on 5/5/12.
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

#import "HeaderNavBarImage.h"


@implementation UIImage (HeaderImage)

-(UIImage*)prepareForHeader
{
    CGRect area = CGRectMake(0,0,320,44);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        UIGraphicsBeginImageContextWithOptions(area.size, NO, 2.0f);
    } else {
        UIGraphicsBeginImageContext(area.size);
    }
	[self drawInRect:area];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0, 44); 
	CGContextAddLineToPoint(context, 320, 44);
	CGContextClosePath (context);
    
	[[UIColor blackColor] setStroke];
	
	CGContextSetLineWidth(context, 1.0);
	CGContextDrawPath(context, kCGPathFillStroke);
	
	UIImage * navBarHeaderImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return navBarHeaderImage; 
}

@end
