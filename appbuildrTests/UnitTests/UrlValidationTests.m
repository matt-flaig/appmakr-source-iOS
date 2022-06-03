/*
 * UrlValidationTests.m
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
 * See Also: http://gabriel.github.com/gh-unit/
 */

#import "UrlValidationTests.h"
#import "NSString+url.h"

const NSString* encodedUrl = @"http://www.agenziazavaglia.it/immagine.asp?foto=Piano%20terra%20c33.jpg";
const NSString* urlWithWhiteSpaces = @"http://www.agenziazavaglia.it/immagine.asp?foto=Piano terra c33.jpg";
const NSString* urlWithUnsafeCharacters = @"http://www.agenziazavaglia.it/immagine.asp?foto=Piano\\terra\\c33.jpg";
const NSString* simpleUrl = @"www.google.com";
const NSString* simpleUrlWithProtocol = @"http://www.google.com";
const NSString* simpleUrlWithout3w = @"google.com";
const NSString* simpleUrlWithout3wProtocol = @"http://google.com";
const NSString* longUrl = @"http://www.youtube.com/watch?v=8H_sB2yaIcE&feature=g-all-blg";
const NSString* simpleText = @"hello_world";

@implementation UrlValidationTests

-(void)testValidationEncoded
{
    GHAssertTrue([encodedUrl isValidEncoded], @"%@ -- should be the valid encoded string", encodedUrl);
    GHAssertTrue([simpleText isValidEncoded], @"%@ -- should be the valid encoded string", simpleText);
    GHAssertTrue([simpleUrl isValidEncoded], @"%@ -- should be the valid encoded string", simpleUrl);
    GHAssertTrue([simpleUrlWithProtocol isValidEncoded], @"%@ -- should be the valid encoded string", simpleUrlWithProtocol);
    GHAssertTrue([simpleUrlWithout3w isValidEncoded], @"%@ -- should be the valid encoded string", simpleUrlWithout3w);
    GHAssertTrue([simpleUrlWithout3wProtocol isValidEncoded], @"%@ -- should be the valid encoded string", simpleUrlWithout3wProtocol);
    GHAssertTrue([longUrl isValidEncoded], @"%@ -- should be the valid encoded string", longUrl);
    GHAssertFalse([urlWithWhiteSpaces isValidEncoded], @"%@ -- should be the not valid encoded string", urlWithWhiteSpaces);
    GHAssertFalse([urlWithUnsafeCharacters isValidEncoded], @"%@ -- should be the not valid encoded string", urlWithUnsafeCharacters);
}

-(void)testValidationUrlFormat
{
    GHAssertTrue([encodedUrl isValidUrl], @"%@ -- should be the valid url", encodedUrl);
    GHAssertFalse([simpleText isValidUrl], @"%@ -- should be the not valid url", simpleText);
    GHAssertFalse([simpleUrl isValidUrl], @"%@ -- should be the not valid url", simpleUrl);
    GHAssertTrue([simpleUrlWithProtocol isValidUrl], @"%@ -- should be the valid url", simpleUrlWithProtocol);
    GHAssertFalse([simpleUrlWithout3w isValidUrl], @"%@ -- should be the not valid url", simpleUrlWithout3w);
    GHAssertTrue([simpleUrlWithout3wProtocol isValidUrl], @"%@ -- should be the valid url", simpleUrlWithout3wProtocol);
    GHAssertTrue([longUrl isValidUrl], @"%@ -- should be the valid url", longUrl);
    GHAssertFalse([urlWithWhiteSpaces isValidUrl], @"%@ -- should be the not valid url", urlWithWhiteSpaces);
    GHAssertFalse([urlWithUnsafeCharacters isValidUrl], @"%@ -- should be the not valid url", urlWithUnsafeCharacters);
}

-(void)testCorrectUrl
{
    GHAssertNotNil([NSURL URLWithString:[encodedUrl correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[simpleText correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[simpleUrl correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[simpleUrlWithProtocol correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[simpleUrlWithout3w correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[simpleUrlWithout3wProtocol correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[longUrl correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[urlWithWhiteSpaces correctUrlEncodedString]], nil);
    GHAssertNotNil([NSURL URLWithString:[urlWithUnsafeCharacters correctUrlEncodedString]], nil);
}

@end
