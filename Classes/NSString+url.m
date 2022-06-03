/*
 * NSString+url.m
 * appbuildr
 *
 * Created on 7/24/12.
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

#import "NSString+url.h"


@implementation NSString (NSString_url)

#pragma mark validation
-(BOOL)isValidEncoded
{
    return [NSURL URLWithString:self] != nil;
}

-(BOOL)isValidUrl
{
    NSURL *candidateURL = [NSURL URLWithString:self];
    // WARNING > "test" is an URL according to RFCs, being just a path
    // so you still should check scheme and all other NSURL attributes you need
    
    if (candidateURL && candidateURL.scheme && candidateURL.host) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark encoded
-(NSString*)correctUrlEncodedString
{
    if([self isValidEncoded])
    {
        return self;
    }
    else
    {
        return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}


@end
