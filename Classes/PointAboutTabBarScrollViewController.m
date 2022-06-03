//
//  PointAboutTabBarScrollViewController.m
//  Kaplan
//
//  Created by William M. Johnson on 11/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PointAboutTabBarScrollViewController.h"
#import "PointAboutTabBarScrollView.h"
#import "PointAboutTableViewController.h"
#import "FeedTableViewController.h"
#import "TabBarIconButton.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalVariables.h"
#import "ModuleFactory.h"
#import "SystemVersion.h"

#define TABBAR_TEXT_FONT_SIZE 11.0
//Added a different implementation of parentViewController so that you can add the PointAboutTabBarScrollViewController to it.
/*@interface UIViewController (Internal)
@property(nonatomic, readwrite, retain) UIViewController * parentViewController;

@end

@implementation UIViewController (Internal)
@dynamic parentViewController;

-(void)setParentViewController:(UIViewController * )p
{
	_parentViewController = p;
	
}
@end*/

#pragma mark comments about this claas
/*************************** NOTE *********************************************
Note: There is an issue with the setting of title to viewControllers in the
PointAboutTabBarScrollViewController. Current Version has check for vc.tabBarItem.title
but not for vc.title in "setViewCOntrollers" method. This might create a crash,
if the title of the view controller is not set.
********************************************************************************/
#pragma mark end comments
@interface PointAboutTabBarScrollViewController (Internal)

-(void)setViewControllers:(NSArray *)vControllers;
-(void)setButtonOnState:(UIButton *)button;
-(void)setButtonOffState:(UIButton *)button;
-(void)setBackButtonForController:(UIViewController*) controller;
-(void)setBackButtonTitle: (NSString*) title;
@end


@implementation PointAboutTabBarScrollViewController
@synthesize pointAboutTabBarScrollView;
@synthesize displayTop;
@synthesize displayType;
@synthesize viewControllers;
@synthesize tabBarBackgroundImageView;
@synthesize tabBarBackgroundColor;
@synthesize tabBarButtons;

-(id)initWithViewControllers:(NSArray *)vControllers displayType:(PointAboutTabBarDisplayType)tabBarDisplayType displayTop:(bool)tabBarDisplayTop {
	if ((self = [self initWithNibName:nil bundle:nil])) {
		displayTop = tabBarDisplayTop;
		displayType = tabBarDisplayType;
		tabBarButtons = [[NSMutableArray alloc]init];
		[self setViewControllers:vControllers];
        [GlobalVariables addObserver:self selector:@selector(OnConfigUpdate:)];
	}	
	return self;
}

-(void)setViewControllers:(NSArray *)vControllers
{
	viewControllers = [vControllers retain];
}


-(void)resize {
	DebugLog(@"resizing layout");
	float maxWidth = self.view.bounds.size.width; 
	float totalButtonsWidth = 0;
	float minMargin=10;
	float scrollViewHeight = 40.0;

	
	for ( UIButton* button in tabBarButtons) {
		totalButtonsWidth += button.frame.size.width;
	//	button.hidden = YES;
	}
	
	float leftOverMargin = maxWidth - totalButtonsWidth;
	float margin = leftOverMargin / ([viewControllers count] + 1);
	margin =  margin < minMargin ? minMargin : margin;
	float originX = margin;
	for ( int i = 0; i < [viewControllers count]; i++ ) {
		
		UIViewController* viewController = (UIViewController *)[viewControllers objectAtIndex:i];
		UIButton* barButton = [tabBarButtons objectAtIndex:i];	
			
		CGRect barButtonFrame;
		barButtonFrame.size = CGSizeMake(barButton.frame.size.width, barButton.frame.size.height);	
		barButtonFrame.origin.x =originX;
		barButtonFrame.origin.y = 5;
		barButton.frame = barButtonFrame;
		
		scrollViewHeight = barButton.frame.size.height;
		CGRect contentFrame = pointAboutTabBarScrollView.contentView.frame;
		viewController.view.frame = CGRectMake(0,0, contentFrame.size.width, contentFrame.size.height);

		//we need to increase the origin x by the size of the of button for the next loop.
		originX += (barButton.frame.size.width + margin)    ;
	}
	
	if ( self.tabBarBackgroundImageView ) {
		scrollViewHeight = self.tabBarBackgroundImageView.image.size.height;
	} else {
		scrollViewHeight += 10;  //adds vertical padding to the background scrollview
	}
	
	float scrollViewY = 0;
	float contentViewY = scrollViewHeight;
	if( !displayTop ) {
		scrollViewY = self.view.frame.size.height - scrollViewHeight;		
		contentViewY = 0;
	}		
	CGRect scrollFrame = CGRectMake(0, scrollViewY, self.view.frame.size.width, scrollViewHeight);
	pointAboutTabBarScrollView.tabBarScrollView.frame = scrollFrame;
	pointAboutTabBarScrollView.tabBarScrollView.contentSize = CGSizeMake(originX, scrollViewHeight );
	
	pointAboutTabBarScrollView.contentView.frame = CGRectMake(0, contentViewY,
															  self.view.frame.size.width,self.view.frame.size.height-scrollViewHeight);
	//WE'LL NOW LAYOUT THE ARROWS THAT INDICATE BUTTON OVERFLOW.  THESE ARE HIDDEN WHEN STARTING
	//THEN MANAGED THROUGH THE SCROLLDIDVIEW DELEGATE METHOD
	float arrowPadding = 5.0;
	float centerY = pointAboutTabBarScrollView.tabBarScrollView.center.y - (tmaLeftView.image.size.height/2);
	float rightArrowX = pointAboutTabBarScrollView.tabBarScrollView.frame.size.width - tmaRightView.image.size.width - arrowPadding;
	tmaRightView.frame = CGRectMake( rightArrowX, centerY, tmaRightView.image.size.width,tmaRightView.image.size.height);
	tmaLeftView.frame = CGRectMake( arrowPadding, centerY, tmaLeftView.image.size.width, tmaLeftView.image.size.height);
	if( pointAboutTabBarScrollView.tabBarScrollView.contentSize.width > pointAboutTabBarScrollView.tabBarScrollView.frame.size.width ) {
		tmaRightView.hidden = NO;
	}
}
- (void)scrollViewDidScroll:(UIScrollView *) scrollView { 
	
	CGPoint	scrollerPoint = scrollView.contentOffset;
	CGSize contentSize = scrollView.contentSize;
	CGFloat remainingSize = contentSize.width - scrollerPoint.x;
	if( scrollerPoint.x > 0 ) {
		tmaLeftView.hidden = NO;
	} else {
		tmaLeftView.hidden = YES;
	}
	if (remainingSize > scrollView.frame.size.width){
			tmaRightView.hidden = NO;
	} else {
			tmaRightView.hidden = YES;
	}	
}

-(void)buttonSelected:(UIButton	*)sender forControlEvents:(UIEvent *)event
{
	//remove the current viewcontroller from the view
	if (selectedButton != sender) 
	{
		//WE NEED TO REMOTE THE PREVIOUS VIEW CONTROLLER FROM THE SUPERVIEW
		[self setButtonOffState:selectedButton];
		[selectedViewController viewWillDisappear:NO];
		[selectedViewController.view removeFromSuperview];	
	
		//NOW LETS ADD THE NEW VIEW	TO THE SUPER VIEW
		selectedViewController = (UIViewController *)[viewControllers objectAtIndex:sender.tag];
        [self setBackButtonForController:selectedViewController];
		
		CGRect contentFrame = pointAboutTabBarScrollView.contentView.frame;
		selectedViewController.view.frame = CGRectMake(0,0, contentFrame.size.width, contentFrame.size.height);
		[pointAboutTabBarScrollView.contentView addSubview:selectedViewController.view];

        if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
            [selectedViewController viewWillAppear:YES];
            [selectedViewController viewDidAppear:YES];
        }

		selectedButton = sender;
		[self setButtonOnState:selectedButton];
	}
	
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[self resize];
	[selectedViewController viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[selectedViewController viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[selectedViewController viewWillDisappear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    if([GlobalVariables templateType] == AppMakrScrollTemplate)
    {           
        self.navigationItem.leftBarButtonItem = [self createBackToMainMenuBtnItem];
    }
    
    if(self.headerImage)
        self.title = nil;

	// a temporary fix for the viewDidLoad is getting called more then once
	if( tabBarButtons && ([tabBarButtons count] > 2 ) )
		return;
	
	self.view.backgroundColor = [UIColor darkGrayColor]; //DEFAULT BACKGROUND COLOR
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.view.autoresizesSubviews = YES;
	
	CGRect scrollFrame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
	pointAboutTabBarScrollView = [[PointAboutTabBarScrollView alloc] initWithFrame:scrollFrame];
	pointAboutTabBarScrollView.displayTop = self.displayTop;
	pointAboutTabBarScrollView.tabBarScrollView.delegate = self;
	[self.view addSubview:pointAboutTabBarScrollView];
	
	if ( self.tabBarBackgroundImageView ) {
		[pointAboutTabBarScrollView.tabBarScrollView addSubview:self.tabBarBackgroundImageView];
	}
	
	DebugLog(@"creating buttons for the tabbar first");
	for ( int i = 0; i < [viewControllers count]; i++ ) {
		PointAboutViewController* viewController = (PointAboutViewController *)[viewControllers objectAtIndex:i];
		
		UIButton *barButton = nil;
		if ([viewController conformsToProtocol:@protocol(PointAboutViewControllerProtocol)]) 
		{
		   viewController.pointAboutTabBarScrollViewController = self;	
		   barButton = viewController.tabBarButton;

		}
		else 
		{
			barButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			
		}

		
				
		if( self.displayType == POINTABOUT_TABBAR_DISPLAY_TEXT ) {
			barButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[barButton setTitle:viewController.title forState:UIControlStateNormal];
			[barButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
			barButton.backgroundColor = [UIColor blackColor];
			barButton.alpha = .75;
			barButton.layer.cornerRadius = 10;
			
			CGRect barButtonFrame;
			barButtonFrame.size = [barButton.currentTitle sizeWithFont:[UIFont boldSystemFontOfSize:TABBAR_TEXT_FONT_SIZE] constrainedToSize:CGSizeMake(320, 20) lineBreakMode:UILineBreakModeWordWrap];
			barButtonFrame.size.width += 20;
			barButtonFrame.size.height += 6;
			barButton.frame = barButtonFrame;
			[self setButtonOffState:barButton];
		} 
		else 
		{
			CGRect barButtonFrame;
			UIImage *imageForNormalState = [barButton imageForState: UIControlStateNormal];
			barButtonFrame.size = imageForNormalState.size;
			barButton.frame = barButtonFrame;
		}
		barButton.adjustsImageWhenHighlighted = NO;
		barButton.tag = i;
		[barButton addTarget:self action:@selector(buttonSelected:forControlEvents:) forControlEvents:UIControlEventTouchUpInside];
		[pointAboutTabBarScrollView.tabBarScrollView addSubview:barButton];
		[tabBarButtons addObject:barButton];
	}

	selectedButton = [tabBarButtons objectAtIndex:0];
	[self setButtonOnState:selectedButton];
	selectedViewController = [viewControllers objectAtIndex:0];
    [self setBackButtonForController:selectedViewController];
	[pointAboutTabBarScrollView.contentView addSubview: selectedViewController.view];
	pointAboutTabBarScrollView.tabBarScrollView.backgroundColor = self.tabBarBackgroundColor;
	pointAboutTabBarScrollView.tabBarScrollView.showsHorizontalScrollIndicator = NO;

	
	//THE FOLLOWING WILL SETUP THE TABBAR ARROWS WHICH ARE SHOWN WHEN SCROLLING BACK AND FORTH.
	UIImage *topMenuArrowRight = [UIImage imageNamed:@"/tabbar_controller_resources/TabBarScrollViewRightArrow.png"];
	tmaRightView = [[UIImageView alloc] initWithImage:topMenuArrowRight];
	tmaRightView.hidden = YES;
	[pointAboutTabBarScrollView addSubview:tmaRightView];
	
	UIImage *topMenuArrowLeft = [UIImage imageNamed:@"/tabbar_controller_resources/TabBarScrollViewLeftArrow.png"];
	tmaLeftView = [[UIImageView alloc] initWithImage:topMenuArrowLeft];
	tmaLeftView.hidden = YES;
	[pointAboutTabBarScrollView addSubview:tmaLeftView];
}

-(void)selectTheProfileView{

	[self setButtonOffState:selectedButton];
	selectedButton = [tabBarButtons objectAtIndex:2];
	//WE NEED TO REMOTE THE PREVIOUS VIEW CONTROLLER FROM THE SUPERVIEW
	[self setButtonOffState:selectedButton];
	[selectedViewController viewWillDisappear:NO];
	[selectedViewController.view removeFromSuperview];	
	
	//NOW LETS ADD THE NEW VIEW	TO THE SUPER VIEW
	selectedViewController = (UIViewController *)[viewControllers objectAtIndex:2];
	
	CGRect contentFrame = pointAboutTabBarScrollView.contentView.frame;
	selectedViewController.view.frame = CGRectMake(0,0, contentFrame.size.width, contentFrame.size.height);
	[selectedViewController viewWillAppear:NO];
	[pointAboutTabBarScrollView.contentView addSubview:selectedViewController.view];
	
	[self setButtonOnState:selectedButton];
}

-(void)selectTheActivityView{
	
	[self setButtonOffState:selectedButton];
	selectedButton = [tabBarButtons objectAtIndex:0];
	//WE NEED TO REMOTE THE PREVIOUS VIEW CONTROLLER FROM THE SUPERVIEW
	[self setButtonOffState:selectedButton];
	[selectedViewController viewWillDisappear:NO];
	[selectedViewController.view removeFromSuperview];	
	
	//NOW LETS ADD THE NEW VIEW	TO THE SUPER VIEW
	selectedViewController = (UIViewController *)[viewControllers objectAtIndex:0];
	
	CGRect contentFrame = pointAboutTabBarScrollView.contentView.frame;
	selectedViewController.view.frame = CGRectMake(0,0, contentFrame.size.width, contentFrame.size.height);
	[selectedViewController viewWillAppear:NO];
	[pointAboutTabBarScrollView.contentView addSubview:selectedViewController.view];
	
	[self setButtonOnState:selectedButton];
}


- (void) setButtonOnState:(UIButton *)button {
	button.titleLabel.alpha = 1;
	button.titleLabel.font = [UIFont boldSystemFontOfSize:TABBAR_TEXT_FONT_SIZE];
	button.selected = YES;
}
- (void)setButtonOffState:(UIButton *)button {
	button.titleLabel.alpha = .5;
	button.titleLabel.font = [UIFont systemFontOfSize:TABBAR_TEXT_FONT_SIZE];
	button.selected = NO;
}

-(void)setBackButtonForController:(UIViewController*) controller
{
    if([controller isKindOfClass:[FeedViewController class]])
    {
        [self setBackButtonTitle:((FeedViewController*)controller).feedKey];
    }
}

-(void)setBackButtonTitle: (NSString*) title
{
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil]autorelease];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)hideTabBar{
	if (!pointAboutTabBarScrollView.tabBarScrollView.hidden){
		pointAboutTabBarScrollView.frame = CGRectMake(pointAboutTabBarScrollView.frame.origin.x, 
												  pointAboutTabBarScrollView.frame.origin.y, 
												  pointAboutTabBarScrollView.frame.size.width, 
												  pointAboutTabBarScrollView.frame.size.height 
												  + pointAboutTabBarScrollView.tabBarScrollView.frame.size.height);
		pointAboutTabBarScrollView.tabBarScrollView.hidden = YES;
		[pointAboutTabBarScrollView setNeedsDisplay];
		[pointAboutTabBarScrollView.tabBarScrollView setNeedsDisplay];
	}
}

-(void)unHideTabBar{
	if (pointAboutTabBarScrollView.tabBarScrollView.hidden){
		pointAboutTabBarScrollView.frame = CGRectMake(pointAboutTabBarScrollView.frame.origin.x, 
												  pointAboutTabBarScrollView.frame.origin.y, 
												  pointAboutTabBarScrollView.frame.size.width, 
												  pointAboutTabBarScrollView.frame.size.height 
												  /*- 48*/ - pointAboutTabBarScrollView.tabBarScrollView.frame.size.height);
		pointAboutTabBarScrollView.tabBarScrollView.hidden = NO;
		[pointAboutTabBarScrollView setNeedsDisplay];
		[pointAboutTabBarScrollView.tabBarScrollView setNeedsDisplay];
	}
}

- (void)dealloc {
    [GlobalVariables removeObserver:self];
	[tmaRightView release];
	[blankImageView release];
	[tabBarButtons release];
	
	[tmaLeftView release];
	[leftBlankImageView release];
	[pointAboutTabBarScrollView release];
	[viewControllers release];
    [super dealloc];
}

#pragma mark - update configs

-(void) OnConfigUpdate: (NSNotification*) notification
{
    if(self.view == nil)
        return;
    
    NSDictionary* configs = [GlobalVariables configsForModulePath:self.modulePath];
    
    if([[[GlobalVariables getPlist] objectForKey:@"configuration"] objectForKey:@"header_image"] == nil)
        self.title = [ModuleFactory tabTitle:configs];
    
    for(UIViewController* controller in viewControllers)
    {
        if([controller isKindOfClass:[MasterController class]])
        {
            NSDictionary* controllerCongig = [GlobalVariables configsForModulePath:((MasterController*)controller).modulePath];
            [[tabBarButtons objectAtIndex:[viewControllers indexOfObject:controller]] setTitle:[ModuleFactory tabTitle:controllerCongig] forState:UIControlStateNormal];
        }
    }
}

-(void)setHeaderImage:(UIImage *)newHeaderImage
{
    [headerImage release];
    headerImage = [newHeaderImage retain];
    
    for(UIViewController* controller in self.viewControllers)
    {
        if([controller isKindOfClass:[MasterController class]])
            ((MasterController*)controller).headerImage = newHeaderImage;
    }
}

@end
