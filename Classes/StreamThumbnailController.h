/*
 * StreamThumbnailController.h
 * appbuildr
 *
 * Created on 7/25/12.
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "Feed.h"
#import "FeedService.h"
#import "AppMakrURLDownload.h"
#import "MasterController.h"
#import "RefreshTableHeaderView.h"
#import "AdsControllerDelegate.h"

@class StreamThumbnailController;

@protocol StreamThumbnailControllerDelegate<NSObject>

@optional
    -(void)startShowStream:(StreamThumbnailController*)controller;
    -(void)comleteShowStream:(StreamThumbnailController*)controller;

@required
    -(UIView*)getStreamElementForIndex:(int) index withFrame:(CGRect) gridFrame;

@end

@interface StreamThumbnailController : MasterController<UIScrollViewDelegate, FeedServiceDelegate, AdsControllerCallback>
{
@private
	UIScrollView			*streamScrollView;
	UIActivityIndicatorView *loadingIndicatorView;
	NSString				*streamFeedURLString;
	NSString				*feedKey;
	Feed					*streamFeed;
	BOOL					feedIsLoaded;
	BOOL					isLoading;
	RefreshTableHeaderView  *refreshHeaderView;
    FeedService				*theFeedService;
    id<AdsController>       adManager;
}

@property(retain)FeedService *theFeedService;
@property(retain)Feed		 *streamFeed;
@property(nonatomic, retain) NSString* streamFeedURLString;
@property(nonatomic, retain) NSString* feedKey;

-(id)initWithFeedURL:(NSString *) streamFeedURL title:(NSString *)aTabTitle delegate: (id<StreamThumbnailControllerDelegate>)delegate;
- (void)displayThumbnails;

@end
