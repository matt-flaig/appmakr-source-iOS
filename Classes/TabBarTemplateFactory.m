/*
 * TabBarTemplateFactory.m
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

#import "TabBarTemplateFactory.h"
#import "TabBarTemplate.h"
#import "ModuleFactory.h"
#import "MasterController.h"
#import "HeaderNavBarImage.h"
#import "CustomNavigationControllerFactory.h"

@interface TabBarTemplateFactory()
-(UIColor*)headerColor:(NSDictionary*) configuration;
-(NSDictionary*)prepareSavedOrderForModules:(NSArray*)modules;
@end

@implementation TabBarTemplateFactory

-(UIColor*)headerColor:(NSDictionary*) configuration
{
    NSNumber *header_bg_red = (NSNumber *)[configuration objectForKey:@"header_bg_red"];
    NSNumber *header_bg_green = (NSNumber *)[configuration objectForKey:@"header_bg_green"];
    NSNumber *header_bg_blue = (NSNumber *)[configuration objectForKey:@"header_bg_blue"];
    
    UIColor *headerBgColor = nil;
    if( header_bg_red  && header_bg_green && header_bg_blue) {
        CGFloat bgRed = [header_bg_red floatValue]/255.0f;
        CGFloat bgGreen =[header_bg_green floatValue]/255.0f;
        CGFloat bgBlue = [header_bg_blue floatValue]/255.0f;
        headerBgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
    }   
    return headerBgColor;
}

-(NSDictionary*)prepareSavedOrderForModules:(NSArray*)modules
{
    NSDictionary *savedTabBarItems = [TabBarTemplate savedTabBarItems];
	
	//we should also reset the tab order if the count's don't match
	if ( [modules count] != [savedTabBarItems count] ) {
		savedTabBarItems = nil;
	}
	//this is for the case of when a user upgrades an app with more/different named tabs
	//than what existed before.  if one of the keys doesn't exist then we should reset the saved
	//order and start with the default order
	if( savedTabBarItems ) {
		for( int i = 0; i < [modules count]; i++ ) {
			NSDictionary* tabBarView = (NSDictionary *)[modules objectAtIndex:i];
			NSString* tabTitle = [[tabBarView objectForKey:@"fields"] objectForKey:@"name"];
			id controllerOrder = [savedTabBarItems objectForKey: tabTitle];
			//if the item doesn't exist, clear out the saved order
			if (!controllerOrder) {
				[TabBarTemplate clearSavedTabOrder];
				savedTabBarItems = nil;
				break;
			}
		}
	}
    return savedTabBarItems;
}

-(id<PlatformTemplate>)createTemlateWithConfiguration:(NSDictionary*) configuration modules: (NSArray*)modules
{
	NSDictionary *savedTabBarItems = [self prepareSavedOrderForModules:modules];
    
    UIImage * headerImage = nil;
    if( ([configuration objectForKey:@"header_image"] != nil) )
    { 
        headerImage = [[UIImage imageNamed:@"header_image.png"] prepareForHeader];
    }	
	
   	UINavigationController* sortedViewControllers[[modules count]+1]; // Why +1 ?
	//setup the tabs
	for( int i = 0; i < [modules count]; i++ ) {
		NSDictionary *module		= (NSDictionary *)[modules objectAtIndex:i];
        UIViewController* moduleController = [ModuleFactory getViewControllerForModule:module atIndex:i];
		
        if (moduleController) 
		{	
            NSDictionary *fields		= [module objectForKey:@"fields"];
            NSString *tabTitle			= [fields objectForKey:@"name"];
            NSString *iconName			= [fields objectForKey:@"icon"];
            NSString *tabBarImageName	= [NSString stringWithFormat:@"/tabbar_images/%@", iconName];
            UIImage	*image				= [UIImage imageNamed: tabBarImageName ];
            
            
            if ([moduleController isKindOfClass:[MasterController class]]) 
            {
                MasterController * controller = (MasterController *)moduleController;
                controller.headerImage = headerImage;
            }
                   
            UINavigationController *aNavigationController = [CustomNavigationControllerFactory createCustomNavigationControllerWithRootController:moduleController];
            aNavigationController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:tabTitle image:image tag:i] autorelease];	
            
            if( savedTabBarItems ) {
                int idx = [(NSNumber *)[savedTabBarItems objectForKey: tabTitle] intValue];
                sortedViewControllers[idx] = aNavigationController;
            } else {
                sortedViewControllers[i] = aNavigationController;
            };
		}
	}
    
    NSArray *tabBarControllersSorted = [NSArray arrayWithObjects:sortedViewControllers count:[modules count]];
    TabBarTemplate* template = [[TabBarTemplate alloc]initWithControllers:tabBarControllersSorted];
    template.headerBgColor = [self headerColor:configuration];
    
    return [template autorelease];
}
@end