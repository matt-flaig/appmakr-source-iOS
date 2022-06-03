/*
 * AppMakrDateTimeConvertorTest.m
 * appbuildr
 *
 * Created on 4/5/12.
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
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import "AppMakrDateTimeConvertorTest.h"

#define DESTINATION_FORMAT @"EEE, d MMM yyyy h:mm:ss a"

@implementation AppMakrDateTimeConvertorTest

-(void)setUpClass
{
    convertor = [[AppMakrDateTimeConvertor alloc]initWithDestinationFormat:DESTINATION_FORMAT];
}

-(void)tearDownClass
{
    [convertor release];
    convertor = nil;
}

-(void)testCheckConvertorResults
{
    //The results should be in format "Fri, 1 Jan 1937 2:40:27 PM"
    GHAssertNotNil([convertor convertDateTimeString:@"1969-07-21T02:56:15"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"1969-07-21T02:56:15Z"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"1969-07-20T21:56:15-05:00"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"1969-07-21T02:56:15.123Z"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"1969-07-20T21:56:15.123-05:00"], @"");

    GHAssertNotNil([convertor convertDateTimeString:@"Fri, 1 Jan 1937 12:40:27"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"2012-04-04T16:17:08GMT+03:00"], @"");
    GHAssertNotNil([convertor convertDateTimeString:@"Fri, 1 Jan 1937 2:40:27 PM"], @"");    
}

@end
