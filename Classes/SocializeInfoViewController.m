//
//  SocializeInfoViewController.m
//  appbuildr
//
//  Created by Fawad Haider  on 3/2/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "SocializeInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SocializeInfoViewController()
-(void)addBackgroundTo:(UIView*)toolBar withImage:(UIImage*)image;
-(UIView*)getTitleView;
-(void)setStylingOnButton:(UIButton*)button WithNormalImage:(UIImage*)normalStateImage 
		 highlightedImage:(UIImage*)hightlightedStateImage
					title:(NSString*)titleString;
@end

@implementation SocializeInfoViewController
@synthesize topToolBar;
@synthesize splashImage;
@synthesize gotoActivityButton;
@synthesize gotoMainViewButton;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<SocializeInfoViewDelegate>)mydelegate {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		delegate = mydelegate; 
    }
    return self;
}

- (UIView*)getTitleView{
	NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"ToolBarTitle" owner:self options:nil];
	UIView* myview = [ nibViews objectAtIndex: 0];
	return myview;
}


-(void)addBackgroundTo:(UIView*)myview withImage:(UIImage*)image{

	UIImageView *aTabBarBackground = [[UIImageView alloc]initWithImage:image];
	aTabBarBackground.frame = CGRectMake(0, 0, 320, 44);
	///	myview.translucent = NO;
	/// aTabBarBackground.tag = bgTag;
	aTabBarBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight; // Resizes image during rotation
	[myview addSubview:aTabBarBackground];
	[myview sendSubviewToBack:aTabBarBackground];
	[aTabBarBackground release];
	
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];	
	
	// create a spacer between the buttons
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
							   target:nil
							   action:nil];

	spacer.width = 50;
	[buttons addObject:spacer];
	[spacer release];
	
	UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:[self getTitleView]];
	[buttons addObject:leftItem];
	[leftItem release];

	// put the buttons in the toolbar and release them
	[topToolBar setItems:buttons animated:NO];
    [buttons release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.splashImage.layer.cornerRadius = 5.0f;
	
#define kLEFT_CAP 11
#define kTOP_CAP 10
	
 	
	
	UIImage *socializeNavBarBackground = [UIImage imageNamed:@"socialize_resources/socialize-navbar-bg.png"];
	[self addBackgroundTo:self.topToolBar withImage:socializeNavBarBackground];
	
	UIImage * imageNormal = [[UIImage imageNamed:@"socialize_resources/socializeinfo/splash-button-blue.png"]stretchableImageWithLeftCapWidth:kLEFT_CAP topCapHeight:kTOP_CAP] ;
	UIImage * imageHighligted = [[UIImage imageNamed:@"socialize_resources/socializeinfo/splash-button-blue-hover.png"]stretchableImageWithLeftCapWidth:kLEFT_CAP topCapHeight:kTOP_CAP];
	
	[self setStylingOnButton:self.gotoActivityButton WithNormalImage:imageNormal 
				highlightedImage:imageHighligted
					   title:@"Setup my Profile"];	

	imageNormal = [[UIImage imageNamed:@"socialize_resources/socializeinfo/splash-button-dark.png"]stretchableImageWithLeftCapWidth:kLEFT_CAP topCapHeight:kTOP_CAP] ;
	imageHighligted = [[UIImage imageNamed:@"socialize_resources/socializeinfo/splash-button-dark-hover.png"]stretchableImageWithLeftCapWidth:kLEFT_CAP topCapHeight:kTOP_CAP];
	
	[self setStylingOnButton:self.gotoMainViewButton WithNormalImage:imageNormal 
			highlightedImage:imageHighligted
					   title:@"Take me to the app"];	
	
}

-(void)setStylingOnButton:(UIButton*)button WithNormalImage:(UIImage*)normalStateImage 
											highlightedImage:(UIImage*)hightlightedStateImage
											title:(NSString*)titleString
													{

	button.backgroundColor = [UIColor clearColor];
														button.layer.cornerRadius = 8.0;
	button.opaque = NO;
	[button setBackgroundImage:normalStateImage forState:UIControlStateNormal];
	[button setBackgroundImage:hightlightedStateImage forState:UIControlStateHighlighted];
	[button setTitle:titleString forState:UIControlStateNormal];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)gotoActivityPressed:(id)sender{
//	[delegate gotoActivityView];
    [delegate gotoProfileView];
}

-(IBAction)gotoMainViewPressed:(id)sender{
	[delegate swipeUpToMainView];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	self.gotoMainViewButton = nil;
	self.gotoActivityButton = nil;
	self.splashImage = nil;
	self.topToolBar = nil;
    [super dealloc];
}


@end
