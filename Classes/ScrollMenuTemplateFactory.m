/*
 * ScrollMenuTemplateFactory.m
 * appbuildr
 *
 * Created on 4/27/12.
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

#import "ScrollMenuTemplateFactory.h"
#import "ModuleFactory.h"
#import "MasterController.h"
#import "AppMakrUINavigationBarBackground.h"
#import "ScrollMenuTemplate.h"
#import "CustomNavigationControllerFactory.h"
#import "HeaderNavBarImage.h"

@implementation ScrollMenuTemplateFactory


-(id<PlatformTemplate>)createTemlateWithConfiguration:(NSDictionary*) configuration modules: (NSArray*)modules
{
    UIImage * headerImage = nil;
    if( ([configuration objectForKey:@"header_image"] != nil) )
    { 
        headerImage = [[UIImage imageNamed:@"header_image.png"] prepareForHeader];
    }	
    
    NSMutableArray* menuItems = [NSMutableArray arrayWithCapacity: [modules count]]; 
	//setup the tabs
	for( int i = 0; i < [modules count]; i++ ) {
		NSDictionary *module		= (NSDictionary *)[modules objectAtIndex:i];
        
        UIViewController* moduleController = [ModuleFactory getViewControllerForModule:module atIndex:i];
		if (moduleController ) 
		{	
            if ([moduleController isKindOfClass:[MasterController class]]) 
            {
                    MasterController * controller = (MasterController *)moduleController;
                    controller.headerImage = headerImage;
                    controller.homeMenuButton  = [UIImage imageNamed:@"nav_btn_home.png"] ;
            }
            		       
            
            NSDictionary *fields	= [module objectForKey:@"fields"];
            NSString *title			= [fields objectForKey:@"name"];
            NSString *iconName      = [NSString stringWithFormat:@"/tabbar_images/%@", [fields objectForKey:@"icon"] ];
            UIImage	*icon			= [UIImage imageNamed: iconName];
            UINavigationController *aNavigationController = [CustomNavigationControllerFactory createCustomNavigationControllerWithRootController:moduleController];
            
            NSDictionary* menuItem = [NSDictionary dictionaryWithObjectsAndKeys: aNavigationController, @"controller", icon, @"icon", title, @"title", nil];
            [menuItems addObject:menuItem];
        }
	}
    
    ScrollMenuTemplate* template = [[ScrollMenuTemplate alloc]initWithMenuItems:menuItems];
    return [template autorelease];
}

@end
