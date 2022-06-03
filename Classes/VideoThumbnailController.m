/*
 * VideoThumbnailController.m
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

#import "VideoThumbnailController.h"
#import "FeedObjects.h"
#import "FeedService.h"
#import "YouTubeEmbededView.h"
#import "VimeoEmbededView.h"


@interface VideoThumbnailController()
-(void) setUserInterfaceEnable:(BOOL)key;
@end

@implementation VideoThumbnailController
@synthesize isVideoProcessing;

-(id)initWithFeedURL:(NSString *) streamFeedURL title:(NSString *)aTabTitle
{
    if( (self = [super initWithFeedURL:streamFeedURL title:aTabTitle delegate:self]) ) {
        thumbViews = [[NSMutableArray alloc]initWithCapacity:1];
	}
	return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.isVideoProcessing = NO;
    
    [self addObserver:self forKeyPath:@"isVideoProcessing" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidExitFullScreen)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieIsPlayingInFullScreen)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification"
                                               object:nil];
}

-(void)viewWillUnload
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:@"UIMoviePlayerControllerDidExitFullscreenNotification"
                                                  object:nil];
    
    [self  removeObserver:self forKeyPath:@"isVideoProcessing" context:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(interfaceOrientation == UIInterfaceOrientationPortrait)
        return YES;
    else
        return self.isVideoProcessing;
}

- (void)dealloc
{
    [thumbViews release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"isVideoProcessing"] )
    {
        [self setUserInterfaceEnable: !self.isVideoProcessing];
    }
}

-(void)cleanCashe
{
    for(UIView* view in thumbViews)
        [view removeFromSuperview];
    
    [thumbViews removeAllObjects];
}

-(void)startShowStream:(StreamThumbnailController*)controller
{
    [self cleanCashe];
}

-(UIView*)getStreamElementForIndex:(int) index withFrame:(CGRect) gridFrame
{
    Entry * entry = [[self.streamFeed entriesInOriginalOrder] objectAtIndex:index];
    
    NSURL* videoUrl = [NSURL URLWithString:entry.url];

    UIView* gridView = nil;
    if([videoUrl.host rangeOfString:@"youtube.com"].location != NSNotFound)
    {
        gridView = [[[YouTubeEmbededView alloc]initWithStringAsURL:entry.url frame:gridFrame]autorelease];
    }
// temporary disable according to     
//    else if([videoUrl.host rangeOfString:@"vimeo.com"].location != NSNotFound)
//    {
//        gridView = [[[VimeoEmbededView alloc]initWithStringAsURL:videoUrl.lastPathComponent frame:gridFrame]autorelease];
//        ((VimeoEmbededView*)gridView).videoDelegate = self;
//    }
    else
    {
        UIImage* background = [UIImage imageNamed: @"/blank_image_small.png"];
        gridView = [[UIImageView alloc]initWithImage:background];
        gridView.frame = gridFrame;
    }
    
    [thumbViews addObject:gridView];
                    
    return gridView;
}

#pragma mark video player events

-(void)movieIsPlayingInFullScreen
{
    [self.navigationController setNavigationBarHidden: YES animated:NO];
    self.isVideoProcessing = YES;
}

- (void)moviePlayerDidExitFullScreen
{
    self.isVideoProcessing = NO;
   
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        UIViewController *mVC = [[[UIViewController alloc] init] autorelease];
        [self presentModalViewController:mVC animated:NO];
        [self dismissModalViewControllerAnimated:NO];
    }
    [self.navigationController setNavigationBarHidden: NO animated:NO];
}

-(void) onPlaybackStarted
{
    self.isVideoProcessing = YES;
}

-(void) setUserInterfaceEnable:(BOOL)key
{
    if(!key && ![NetworkCheck hasInternet])
        return;
        
    self.view.userInteractionEnabled = key;
    self.navigationController.navigationBar.userInteractionEnabled = key;
}

@end
