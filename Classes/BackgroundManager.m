/*
 * BackgroundManager.m
 * appbuildr
 *
 * Created on 5/16/12.
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

#import "BackgroundManager.h"
#import "VideoPlayerViewController.h"
#import "UIImage+Resize.h"

@interface BackgroundManager()
@property(nonatomic, retain) VideoPlayerViewController* liveBackground;
@end

@implementation BackgroundManager
@synthesize style = _style;
@synthesize backgroundResource  = _backgroundResource;
@synthesize liveBackground = _liveBackground;

-(void)dealloc
{
    self.backgroundResource = nil;
    self.liveBackground = nil;
    [super dealloc];
}

-(void)addBackgroundToView: (UIView*)view
{
    NSAssert(view, @"View could not be nil");
    
    if(self.style == AppMakrColorBackground)
    {
        view.backgroundColor = (UIColor*)self.backgroundResource;
    }
    else if(self.style == AppMakrImageBackground)
    {
        UIImage* backgroundImage =    [[UIImage imageNamed:(NSString*)self.backgroundResource] resize: CGSizeMake(320, 480)];
        view.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    }
    else
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:(NSString*)self.backgroundResource ofType:nil]];  
        VideoPlayerViewController *player = [[VideoPlayerViewController alloc] init];
        player.URL = url;
        
        NSString  *bgImagePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bgImage.png"];
        UIImage* bgImage = [UIImage imageWithContentsOfFile:bgImagePath];
        if(!bgImage)
        {
            bgImage = [player getImageOnTime:CMTimeMakeWithSeconds(0.0, 600)];
            // Write image to PNG
            [UIImagePNGRepresentation(bgImage) writeToFile:bgImagePath atomically:YES];
        }
        [player setBackgroundImage:bgImage scale:UIViewContentModeScaleAspectFill];
        
        player.view.frame = view.bounds;
        [view addSubview:player.view];

        self.liveBackground = player;
        [player release];
    }
}

-(void)viewWillAppear
{
    [self.liveBackground play];
    
}

-(void)viewWillDisappear
{
    [self.liveBackground pause];
}
@end
