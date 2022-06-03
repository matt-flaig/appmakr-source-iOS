/*
 * VimeoEmbededView.m
 * appbuildr
 *
 * Created on 7/26/12.
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

#import "VimeoEmbededView.h"
#import "GlobalVariables.h"


@implementation VimeoEmbededView
@synthesize videoDelegate;

- (id)initWithStringAsURL:(NSString *)urlString frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.delegate = self;
        
        NSMutableString* requestString = [NSMutableString string];
        if([[GlobalVariables appmakrHost] isEqualToString:@"http://www.stage.appmakr.com"])
            [requestString appendString: @"http://appmakr:Make%40n%40ppForThat@stage.appmakr.com/test/get/?"];
        else
            [requestString appendString: @"http://appmakr.com/test/get/?"];
        
        [requestString appendFormat:@"id=%@&w=%0.0f&h=%0.0f",urlString, frame.size.width, frame.size.height];

        NSURL* requestUrl = [NSURL URLWithString:requestString];
        [self loadRequest:[NSURLRequest requestWithURL:requestUrl]];
        
//        NSString* html = [NSString stringWithFormat:@"<html>"
//                @"<body style=\"margin:0\">"
//                @"<iframe src=\"http://player.vimeo.com/video/%@\" width=\"%0.0f\" height=\"%0.0f\" frameborder=\"0\" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>"
//                @"</body>"
//                @"</html>", 
//                urlString , frame.size.width, frame.size.height];  
//        
//        // Load the html into the webview
//        [self loadHTMLString:html baseURL:nil];
    }
    return self;
}

-(void)dealloc
{
    self.delegate = nil;
    self.videoDelegate = nil;
    
    [super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.scheme isEqualToString:@"callback"])
    {
        if([request.URL.absoluteString isEqualToString:@"callback://play_event"] && [self.videoDelegate respondsToSelector:@selector(onPlaybackStarted)])
        {
            [self.videoDelegate onPlaybackStarted];
        }
        return NO;
    }
    return YES;
}

@end
