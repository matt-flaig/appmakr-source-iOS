/*
 * TabBarTemplate.m
 * appbuildr
 *
 * Created on 4/25/12.
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

#import "TabBarTemplate.h"

@interface UITabBarControllerNoRotate : UITabBarController
@end

@implementation UITabBarControllerNoRotate

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

@end

#pragma mark TabBarTemplate
@implementation TabBarTemplate
@synthesize rootViewController = rootViewController;

-(void)dealloc
{
    [rootViewController release];
    [super dealloc];
}

-(id)initWithControllers:(NSArray*)controllers
{
    self = [super init];
    if(self)
    {
        if ([controllers count] > 1){
            UITabBarController* newTabBarController = [[[UITabBarControllerNoRotate alloc] init] autorelease];
            newTabBarController.viewControllers = controllers;	
            
            rootViewController = [newTabBarController retain];
        }
        else if ([controllers count] == 1) {
            rootViewController = [[controllers objectAtIndex:0] retain];
        }
    }
    return self;
}

-(void)setHeaderBgColor: (UIColor*)color
{
    if(![rootViewController isKindOfClass:[UITabBarController class]])
        return;
    [(UITabBarController*)rootViewController moreNavigationController].navigationBar.tintColor = color;
}

-(UIView*) view
{
    return rootViewController.view;
}

-(void)OnShutdownAction
{
    [self persistTabOrder];
}

#pragma makr TabBarTemplate (utils)

+(NSDictionary*)savedTabBarItems
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"tabBarItemOrder"];
}

+(void) clearSavedTabOrder
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"tabBarItemOrder"];
    [defaults synchronize];
}

-(void) persistTabOrder{
	//THIS WILL STORE THE ORDER OF THE TABBAR CONTROLLERS IF THEY WERE CHANGED.
    if(![rootViewController isKindOfClass:[UITabBarController class]])
        return;
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *controllerNames = [[NSMutableDictionary alloc] init];
    
    UITabBarController* tabBarController = (UITabBarController*)rootViewController;
    
	for( int i =0; i < [tabBarController.viewControllers count]; i++ ) {
		UIViewController *v = (UIViewController *)[tabBarController.viewControllers objectAtIndex:i];
        if(v.tabBarItem.title != nil)
            [controllerNames setObject:[NSNumber numberWithInt:i] forKey:v.tabBarItem.title];
	}
	[defaults setObject:controllerNames forKey:@"tabBarItemOrder"];
	[defaults synchronize];
	[controllerNames release];
}

@end

#pragma mark TabBarTemplateFactory
