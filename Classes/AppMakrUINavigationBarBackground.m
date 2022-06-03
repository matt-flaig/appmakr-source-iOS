//
//  AppMakrUINavigationBarBackground.m
//  appbuildr
//
//  Created by Isaac Mosquera on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppMakrUINavigationBarBackground.h"
#import "BlocksKit.h"

#define IMAGE_KEY "background_image"

@implementation UINavigationBar (UINavigationBarCategory)

- (void)setCustomBackgroundImage:(UIImage*)image
{
    if(image == nil){ //might be called with NULL argument
		return;
	}
    
    if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [self associateValue:image withKey:IMAGE_KEY];
    } 
    else
    {       
        UIImageView *aTabBarBackground = [[[UIImageView alloc]initWithImage:image] autorelease];
        aTabBarBackground.frame = CGRectMake(0, 0, 320, self.frame.size.height);
        
        self.translucent = NO;
        aTabBarBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight; // Resizes image during rotation
        aTabBarBackground.contentMode = UIViewContentModeScaleAspectFit;
        
        [self insertSubview:aTabBarBackground atIndex:0]; 
        [self associateValue:aTabBarBackground withKey:IMAGE_KEY];
    }
    

}

- (void)showCustomBackgroundImage
{
	id image = [self associatedValueForKey: IMAGE_KEY];
	if( image ) 
	{
        if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        } 
        else
        {
            [(UIImageView*)image setHidden: NO];
        }
	}
}

- (void)hideCustomBackgroundImage
{
	id image = [self associatedValueForKey: IMAGE_KEY];
	if( image ) 
	{
        if ([UINavigationBar instancesRespondToSelector:@selector(setBackgroundImage:forBarMetrics:)])
        {
            [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        } 
        else
        {
            [(UIImageView*)image setHidden: YES];
        }
	}
}

- (void)removeCustomBackgroundImage
{
    [self hideCustomBackgroundImage];
    [self associateValue:nil withKey:IMAGE_KEY];
}

@end

