//
//  PhotoAlbumScrollController.m
//  politico
//
//  Created by PointAbout Dev on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PhotoThumbnailController.h"
#import "GlobalVariables.h"
#import "PhotoDataSource.h"
#import "FeedObjects.h"
#import "ImageReference+Extensions.h"
#import <Socialize/Socialize.h>
#import "SZPathBar.h"
#import "SZPathBar+Default.h"

@interface PhotoThumbnailController ()
@property(nonatomic, retain) PhotoDataSource* dataSource;
@property(nonatomic, retain) SZActionBar* sszBar;
@end

@implementation PhotoThumbnailController
@synthesize dataSource = _dataSource;
@synthesize sszBar = _sszBar;

- (void)dealloc 
{
	[imageButtons release];
	[buttonDictionary release];
    self.dataSource = nil;
    self.sszBar = nil;
    [bar release];
    
	[super dealloc];	
}

-(id)initWithFeedURL:(NSString *) streamFeedURL title:(NSString *)aTabTitle {
	if( (self = [super initWithFeedURL:streamFeedURL title:aTabTitle delegate:self]) ) {
        imageButtons = [[NSMutableArray alloc]init];
		buttonDictionary = [[NSMutableDictionary alloc]init];
	}
	return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
       
    if([GlobalVariables socializeEnable] && [GlobalVariables templateType] == AppMakrScrollTemplate)
    {
        NSAssert(self.feedKey, @"Tab name could not be nil!");
        NSAssert(self.streamFeedURLString, @"Feed url could not be nil!");
        
        bar = [[SZPathBar alloc] initWithButtonsMask: SZCommentsButtonMask|SZShareButtonMask|SZLikeButtonMask
                                    parentController: (UIViewController*)self.pointAboutTabBarScrollViewController ? (UIViewController*)self.pointAboutTabBarScrollViewController: self
                                              entity: [SZEntity entityWithKey:self.streamFeedURLString name:self.feedKey]];
        
        [bar applyDefaultConfigurations];
        [self.view addSubview:bar.menu];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayThumbnails];
}

#pragma mark feed service callabcks

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser updateToolbar:(UIToolbar*)toolbar index:(NSUInteger)index
{
    if([GlobalVariables socializeEnable])
    {
        [self.sszBar removeFromSuperview];
        
        Entry* entry = [self.dataSource entryAtIndex:index];
        self.sszBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:  [SZEntity entityWithKey:entry.url name:entry.title != nil ? entry.title: @""] viewController:photoBrowser];

        [toolbar addSubview:self.sszBar];
    }
}

                 
-(void)startShowStream:(StreamThumbnailController*)controller
{
	for (UIView* imgButtons in imageButtons)
		[imgButtons removeFromSuperview];
	
	[imageButtons removeAllObjects];
    [buttonDictionary removeAllObjects];
    
    self.dataSource = [[[PhotoDataSource alloc]initWithFeed:self.streamFeed]autorelease];
}

-(UIView*)getStreamElementForIndex:(int) index withFrame:(CGRect) gridFrame
{
    Entry * entry = [[self.streamFeed entriesInOriginalOrder] objectAtIndex:index];
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = gridFrame;
    imageButton.tag = index;

    imageButton.backgroundColor = [UIColor clearColor];
    
    [imageButton setTag:index];
    [imageButton addTarget:self action:@selector(myButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //if we are	loading from the archive, load the image here
    //if the image needs to be downloaded, we'll deal with that elsewhere
    
    UIImage* buttonImage = [entry.thumbnailImage ImageObject];

    if ( !entry.thumbnailImage ) 
    {
        buttonImage = [UIImage imageNamed: @"/blank_image_small.png"];
        [self.theFeedService fetchThumbnailForEntry:entry];
    } 
    [imageButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [imageButtons addObject:imageButton];
    [buttonDictionary setObject:imageButton forKey:entry.order];
    return imageButton;
}
                 
-(void) feedService:(FeedService *)feedService didFinishFetchingThumbnailForEntry:(Entry *)entry
{   
    UIButton* imageButton = (UIButton *)[buttonDictionary objectForKey:entry.order];	
    DebugLog(@"index for image is %i", imageButton.tag);
    UIImage* currentImage = [entry.thumbnailImage ImageObject];
    [imageButton setBackgroundImage:currentImage forState:UIControlStateNormal];
}
                 
 -(void)myButtonAction:(id)sender 
{
     NSAssert(self.dataSource!=nil, @"Photo data source should be configurated");   
     
     
     [self.theFeedService cancelAllFetchRequests];
     
     MWPhotoBrowser *browser = [[PhotoAdsDetailView alloc] initWithDelegate:self.dataSource];
     browser.displayActionButton = NO;
     browser.viewDelegate = self;
     browser.useCustomToolBar = YES;
     [browser setInitialPageIndex:((UIView *)sender).tag];
     
     // Modal
     UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
     nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
     [self presentModalViewController:nc animated:YES];
     [nc release];
     
     // Release
     [browser release];    
 }

-(void) OnConfigUpdate: (NSNotification*) notification
{
    [super OnConfigUpdate:notification];
    bar.entity = [SZEntity entityWithKey:self.streamFeedURLString name:self.title];
}
@end
