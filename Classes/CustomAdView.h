//
//  CustomAdView.h
//  appbuildr
//
//  Created by Isaac Mosquera on 8/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdsControllerDelegate.h"


@interface CustomAdView : UIWebView<UIWebViewDelegate> {
	id<AdsControllerCallback> proxyDelegate;
}

- (id)initWithFrame:(CGRect)aRect id:(id<AdsControllerCallback>)calledObject;

@property(nonatomic, assign) id<AdsControllerCallback> proxyDelegate;

@end
