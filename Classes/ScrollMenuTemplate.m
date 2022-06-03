/*
 * ScrollMenuTemplate.m
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

#import "ScrollMenuTemplate.h"
#import "ScrollMenuView.h"
#import "MenuIconButton.h"
#import "UIImage+Resize.h"
#import "BackgroundManager.h"
#import "ToolDrawerView.h"
#import "AboutPageViewController.h"
#import "CustomNavigationControllerFactory.h"
#import "Socialize/Socialize.h"

#define kMenuDefaultHeight 120

@interface ScrollMenuTemplate()
@property(nonatomic, retain) ScrollMenuView* menuView;
@property(nonatomic, retain) BackgroundManager* background;
@property(nonatomic, retain) NSArray* menuItems;

-(void) initBackground;
-(void) initSystemMenu;

-(IBAction) onHelpBtnClick;
-(IBAction) onAboutBtnClick;
-(IBAction) onProfileBtnClick;
@end


@implementation ScrollMenuTemplate
@synthesize menuItems = _menuItems;
@synthesize menuView = _menuView;
@synthesize background = _background;

- (id)initWithMenuItems:(NSArray*) menuItems
{
    self = [super init];
    if (self) {
        self.menuItems = menuItems;
        
        // Register itself for delegate notification from all UINavigationControllers
        for (NSDictionary* menuItemInfo in self.menuItems) {
            UIViewController* controller = [menuItemInfo objectForKey:@"controller"];
            if([controller isKindOfClass:[UINavigationController class]])
                ((UINavigationController*) controller).delegate = self;
        }
    }
    return self;
}

- (void)dealloc
{
    self.menuItems = nil;
    self.menuView = nil;
    [super dealloc];
}

- (UIViewController*)rootViewController {
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initBackground];

    self.menuView = [[[ScrollMenuView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, kMenuDefaultHeight)]autorelease];  
   
    const NSUInteger menuItems = [self.menuItems count];    
    for(int i = 0; i < menuItems; i++)
    {     
        
        MenuIconButton *thisView = [MenuIconButton buttonWithType:UIButtonTypeCustom];
        [thisView setTag:i];
        
        [thisView addTarget:self 
                     action:@selector(menuItemClick:)
           forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary* menuItemInfo = [self.menuItems objectAtIndex:i];
        UIImage *bgImage = [[menuItemInfo valueForKey:@"icon"] resize:CGSizeMake(kMenuItemIconSize, kMenuItemIconSize)];
        [thisView setImage:bgImage forState:UIControlStateNormal];     
 
        
        [thisView setTitle:[menuItemInfo valueForKey:@"title"] forState:UIControlStateNormal];
        thisView.titleLabel.font = [UIFont boldSystemFontOfSize:kMenuItemTitleFontSize];
        

        [self.menuView addSubview:thisView];
    }
    [self.menuView layoutIfNeeded];
    [self.menuView  setContentOffset:CGPointMake(self.menuView .contentSize.width/2 - self.menuView.frame.size.width/2, 0.0)]; 
    [self.view addSubview:self.menuView];
    
	if([GlobalVariables enableMainMenu])
        [self initSystemMenu];   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.menuView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.background viewWillAppear];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tmpRect = self.menuView.frame;
                         tmpRect.origin.y = self.menuView.frame.origin.y - self.menuView.frame.size.height;
                         self.menuView.frame = tmpRect;
                     }
                     completion:^(BOOL finished){
                     }]; 
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.background viewWillDisappear];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect tmpRect = self.menuView.frame;
                         tmpRect.origin.y = self.menuView.frame.origin.y + self.menuView.frame.size.height;
                         self.menuView.frame = tmpRect;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)menuItemClick:(id)sender 
{   
    UIViewController* modalController = [[self.menuItems objectAtIndex:[sender tag]] objectForKey:@"controller"];
    modalController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:modalController animated:YES];

}

#pragma  mark navigation delegate

- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(willAppearIn:)])
        [viewController performSelector:@selector(willAppearIn:) withObject:navController];
}

-(void) initBackground
{    
    BackgroundManager* manager = [BackgroundManager new];
    manager.style = [GlobalVariables backgroundStyle];
    if([GlobalVariables backgroundStyle] == AppMakrColorBackground)
        manager.backgroundResource = [GlobalVariables backgroundColor];
    else
        manager.backgroundResource = [NSString stringWithFormat: @"/tabbar_images/%@", [GlobalVariables pathForBackgroundResource]];        

    [manager addBackgroundToView:self.view];
    
    self.background = manager;
    [manager release];
}


#pragma main system menu

- (void)initSystemMenu
{
    if(!([GlobalVariables socializeEnable] || [GlobalVariables helpUrl] || [GlobalVariables aboutPageUrl]))
        return;
    
    ToolDrawerView* mainSystemMenu = [[ToolDrawerView alloc]initInVerticalCorner:kTopCorner andHorizontalCorner:kRightCorner moving:kVertically];
    
    if([GlobalVariables socializeEnable])
    {
        UIButton* profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [profileBtn setImage:[UIImage imageNamed:@"scroll_menu_images/socialize-icon-profile-active.png"] forState:UIControlStateHighlighted];
        [profileBtn setImage:[UIImage imageNamed:@"scroll_menu_images/socialize-icon-profile.png"] forState:UIControlStateNormal];
        [profileBtn addTarget:self action:@selector(onProfileBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [mainSystemMenu appendButton:profileBtn];
    }
    
    if([GlobalVariables helpUrl])
    {
        UIButton* helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpBtn setImage:[UIImage imageNamed:@"scroll_menu_images/help-icon.png"] forState:UIControlStateNormal];
        [helpBtn addTarget:self action:@selector(onHelpBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [mainSystemMenu appendButton:helpBtn];
    }
    
    if([GlobalVariables aboutPageUrl])
    {
        UIButton* aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [aboutBtn setImage:[UIImage imageNamed:@"scroll_menu_images/About-icon.png"] forState:UIControlStateNormal];
        [aboutBtn addTarget:self action:@selector(onAboutBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [mainSystemMenu appendButton:aboutBtn];
    }
    if(mainSystemMenu.subviews.count > 1)
        [self.view addSubview:mainSystemMenu];
    [mainSystemMenu release];
}

-(void) onHelpBtnClick
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GlobalVariables helpUrl]]];
}

-(void) onAboutBtnClick
{
    AboutPageViewController* modalController = [[[AboutPageViewController alloc]init] autorelease];
    UINavigationController *aNavigationController = [CustomNavigationControllerFactory createCustomNavigationControllerWithRootController:modalController];
    aNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:aNavigationController animated:YES];
}

-(void) onProfileBtnClick
{
    // Pass nil to show the current user
    [SZUserUtils showUserProfileInViewController:self user:nil completion:^(id<SZFullUser> user) {
        NSLog(@"Done showing profile");
    }];
}

@end
