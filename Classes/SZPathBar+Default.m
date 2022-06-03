/*
 * SZPathBar+Default.m
 * appbuildr
 *
 * Created on 8/8/12.
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

#import "SZPathBar+Default.h"
#import "GlobalVariables.h"
#import "AboutPageViewController.h"
#import "CustomNavigationControllerFactory.h"
#import "AdsViewController.h"
#import "PointAboutTabBarScrollViewController.h"

@implementation SZPathBar (SZPathBar_Default)

-(void)applyDefaultConfigurations
{   
    CGPoint sp = CGPointMake(self.controller.navigationController.view.frame.size.width - 50, self.controller.navigationController.view.frame.size.height - 70);
    
    if(self.controller.navigationController)
        sp.y -= self.controller.navigationController.navigationBar.frame.size.height;
    if([AdsViewController isAdsAvailible])
        sp.y -= 30;
    if([self.controller isKindOfClass:[PointAboutTabBarScrollViewController class]])
        sp.y -= 30;

    self.menu.startPoint = sp;
    self.menu.mainButton.alpha = 0.5f;
}

@end
