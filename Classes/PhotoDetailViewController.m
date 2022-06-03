//
//  PhotosDetailViewController.m
//  politico
//
//  Created by PointAbout Dev on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "PhotoDetailViewController.h"
#import "CaptionView.h"
#import "PhotoDetailView.h"
#import "AppMakrURLDownload.h"
#import "FeedArchiver.h"
#import "NetworkCheck.h"
#import "ObjectUnarchiver.h"
#import "MD5.h"
#import "UIImage+Resize.h"
#import "ObjectArchiver.h"
#import "FeedObjects.h"
#import "ImageReference+Extensions.h"
#import "AdsViewController.h"
#import "GlobalVariables.h"
#import "CustomNavigationBar.h"

float const FULLPAGE_HEIGHT = 460.0f;
float const PAGE_WIDTH_PORTRAIT = 330.0f;
float const PAGE_WIDTH_LANDSCAPE = 490.0f;

@interface PhotoDetailViewController ()
- (void) presentImageViews;
-(void) createImageForPhotoView:(PhotoDetailView * )photoDetailView;
@property(nonatomic, retain) id<AdsController> adsManager;
@end


@implementation PhotoDetailViewController
@synthesize selectedIndex;
@synthesize theFeedService;
@synthesize adsManager;

- (void)dealloc 
{
    NSNumber * number = [NSNumber numberWithInt:[theFeedService retainCount]];
	
	DebugLog(@"Feed Service retain count:%@",number);
	[theFeedService release];

	[photoFeed release];
	[scrollView release];
	[tabBarTitle release];
	[photoImageViews release];
	[urlDownloads release];
    self.adsManager = nil;
    [super dealloc];
	DebugLog(@"PhotoDetailViewController destroyed!!");
}

-(id)initWithFeed:(Feed *)feed 
{
	if ((self = [super initWithNibName:nil bundle:nil])) 
	{
		photoFeed = [feed retain];
		

		DebugLog(@"the photo details view was initialized and feed entries has %i count", [photoFeed.entries count]);		
		self.hidesBottomBarWhenPushed = YES;
		photoImageViews = [[NSMutableArray alloc] init];	
		urlDownloads = [[NSMutableDictionary alloc]init];
		scrollView = [[UIScrollView alloc] init];
	}
	return self;
}

-(id)initWithFeedID:(id)feedID
{	
	theFeedService = [FeedService new];
	theFeedService.delegate = self;
	photoFeed = (Feed *) [theFeedService.localDataStore entityWithID:feedID];
	
	
	return [self initWithFeed:photoFeed];
	
}

-(void)layoutPhotos {

	float pageWidth = self.view.frame.size.width + 10.0;
	
	scrollView.bounds = CGRectMake( scrollView.bounds.origin.x, scrollView.bounds.origin.y,
								   self.view.frame.size.width + 10.0,self.view.frame.size.height);
	
	scrollView.contentOffset = CGPointMake(selectedIndex * pageWidth, 0);	
	
	for (int i=0; i<[photoFeed.entries count]; i++) {				
		PhotoDetailView *detailView =  (PhotoDetailView *)[photoImageViews objectAtIndex:i];
		detailView.frame = CGRectMake( i * pageWidth, 0, self.view.frame.size.width,self.view.frame.size.height);
	}
	scrollView.contentSize = CGSizeMake( [photoFeed.entries count] * pageWidth,self.view.frame.size.height); 
}
-(void)viewDidLoad {
	//setup array
	DebugLog(@"view is loading");
	
	self.view.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
	self.view.backgroundColor = [UIColor blackColor];
	scrollView.frame = CGRectMake(0, 0, 330, FULLPAGE_HEIGHT);
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.autoresizesSubviews = YES;
	scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	scrollView.pagingEnabled = YES;
	scrollView.delegate = self;
	
	float xPosition = 0.0f;
	float pageWidth = (self.interfaceOrientation == UIInterfaceOrientationPortrait ) ? PAGE_WIDTH_PORTRAIT: PAGE_WIDTH_LANDSCAPE;
	
	
	NSArray * entriesArray = [photoFeed entriesInOriginalOrder];
	DebugLog(@"Entries Array count %i", [entriesArray count]);
	for (int i=0; i<[entriesArray count]; i++) {				
		Entry * entry = [entriesArray objectAtIndex:i];
		CGRect photoFrame = CGRectMake(xPosition, 0, 320, FULLPAGE_HEIGHT);
		PhotoDetailView * photoDetailView = [[PhotoDetailView alloc] 
										   initWithFrame:photoFrame 
										   entry:entry
											 tag:[entry.order intValue]										   
											 delegate: self];
		photoDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoDetailView.autoresizesSubviews = YES;
		[photoDetailView.activityView startAnimating];
		[photoImageViews addObject:photoDetailView];
		[scrollView addSubview:photoDetailView];
		[photoDetailView release];
		
		xPosition += pageWidth;
	}
	scrollView.contentSize = CGSizeMake(xPosition,FULLPAGE_HEIGHT);
	[self.view addSubview:scrollView];
}

-(void) imageButtonAction:(id)sender {
	int tag = ((UIView *)sender).tag;
	DebugLog(@"hiding/showing header and captionview for index %i" ,tag);
	for( PhotoDetailView* photoImageView in photoImageViews) {
		[photoImageView toggleCaptionView];
	}
	[super toggleNavigationBarView];	
}
-(void) viewWillDisappear:(BOOL)animated 
{
	[super viewWillDisappear:animated];
	[self.theFeedService cancelAllFetchRequests];
	[super viewWillDisappear:animated];
	DebugLog(@"PD:cancelling all operations because view will dissapear");
	self.navigationController.navigationBar.alpha = 1.0;
	[self.navigationController.navigationBar setTranslucent:NO];
	//[[URLDownload downloadQueue] cancelAllOperations];
	
	self.theFeedService.delegate = nil;
	self.theFeedService = nil;
	
    self.adsManager.delegate = nil;
    if([self.adsManager respondsToSelector:@selector(stopLoad)])
        [self.adsManager stopLoad];
    [self.adsManager.view removeFromSuperview];
    self.adsManager = nil;
	
}

- (void) presentImageViews {
	//we need to get the image from the cache so we don't load all the images into memory at once.
	//we will get the image before and the image after the selected image as well.
	for (int i = 0; i < [photoImageViews count]; i++ ) {
		PhotoDetailView * photoDetailView = [photoImageViews objectAtIndex:i];
	//	Entry * entry = [photoFeed.entries objectAtIndex:i];
		if ( i >= selectedIndex-1 && i <= selectedIndex+1 ) {
			if ( !photoDetailView.photoImageView.image ) {
				//we now need to pull this image and show it on the screen.
				[photoDetailView.activityView startAnimating];
				[self performSelectorInBackground:@selector(createImageForPhotoView:) withObject:photoDetailView];
			//	[self createImageForPhotoView:photoDetailView];
			}
		} else {
			//this will release the photoimageview from memory.
			photoDetailView.photoImageView.image = nil;
		}
	}	
}

-(UIImage *) resizeImage:(UIImage *)imageToResize
{
	UIImage * newImage = nil;
	if (imageToResize != nil) 
	{
		
		CGSize biggestSize = CGSizeMake(960,640);
	
		
		if( imageToResize.size.height > biggestSize.height || imageToResize.size.width > biggestSize.width )
		{
			
		    newImage = [imageToResize resizedImageWithContentMode:UIViewContentModeScaleAspectFill
																bounds:biggestSize
												  interpolationQuality:1.0];
			NSData * newData = UIImageJPEGRepresentation(newImage, .75);
			if(!newData) 
			{
				newImage = [UIImage imageWithData:newData];
			}
			
		}

	}
	
	if (newImage == nil) 
	{
		newImage = imageToResize;
	}
		
	return newImage;
}

-(void) createImageForPhotoView:(PhotoDetailView * )photoDetailView 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	DebugLog(@"doing work in the background for tag %i", photoDetailView.tag);
	NSArray * entriesArray = [photoFeed entriesInOriginalOrder];
	Entry * entry = [entriesArray objectAtIndex:photoDetailView.tag];
	
	if (photoDetailView.fullSizedImageDownloaded) 
	{
		
		[photoDetailView.activityView stopAnimating];
		if (entry.fullSizedImage != nil) 
	    {
			DebugLog(@"image exists!");
			photoDetailView.photoImageView.image = [entry.fullSizedImage ImageObject];
			photoDetailView.imageStatusLabel.hidden = YES;
		
		} 
		else 
		{
			DebugLog(@"image does not exist!");
			photoDetailView.imageStatusLabel.text = @"No full-sized image currently available.";	
		}
	}
	
	[pool release];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//FeedService *myFeedService = [[FeedService alloc] init];
//	myFeedService.delegate = self;
//	self.theFeedService = myFeedService;
//	[myFeedService release];
//	
	[self.navigationController.navigationBar setHidden:NO];
    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
    {
        [((CustomNavigationBar*)self.navigationController.navigationBar) clearBackground];
    }
	[self.navigationController.navigationBar setTranslucent:YES];
	self.navigationController.navigationBar.alpha = .75;
	//we're saving this title because the parentviewcontroller can dissapear when going back and forth 
	//quick between navigation controllers.
	[self layoutPhotos];
	tabBarTitle = [self.parentViewController.tabBarItem.title retain];
	DebugLog(@"Number of photos %i", [photoImageViews count]);
	DebugLog(@"going to select with index: %i", selectedIndex);
	NSInteger indexIterator = selectedIndex;
	do {
				
		PhotoDetailView * photoDetailView = (PhotoDetailView *)[photoImageViews objectAtIndex:indexIterator];

		photoDetailView.fullSizedImageDownloaded = (photoDetailView.entry.fullSizedImage!=nil);
		if (!photoDetailView.fullSizedImageDownloaded) 
		{
			[self.theFeedService fetchFullSizedImageForEntry:photoDetailView.entry];
		   
		}
		indexIterator++;
		if( indexIterator >= [photoImageViews count] && indexIterator != selectedIndex ) {
			indexIterator = 0;
		}
	} while( indexIterator != selectedIndex );
	
	float pageWidth = (self.interfaceOrientation == UIInterfaceOrientationPortrait ) ? PAGE_WIDTH_PORTRAIT: PAGE_WIDTH_LANDSCAPE;
	scrollView.contentOffset = CGPointMake(selectedIndex * pageWidth, 0);
	DebugLog(@"completed view will appear");
}

#pragma mark FeedService callbacks
-(void) feedService:(FeedService *)feedService didFetchFullSizedImageForEntry:(Entry *)entry
{
	PhotoDetailView * photoDetailView = [photoImageViews objectAtIndex:[entry.order intValue]];
	photoDetailView.fullSizedImageDownloaded = YES;
    [self presentImageViews];
}

-(void) feedService:(FeedService *)feedService didFailFetchingFullSizedImageWithError:(NSError *)error
{
	DebugLog(@"Full-sized image download error: %@ - %@", [error localizedFailureReason],[error localizedDescription]);	
}
-(void) feedServiceDidFinishFetchingFullSizedImage:(FeedService *)feedService
{
	
}

#pragma mark ====================
-(void)createAds
{
    self.adsManager = [AdsViewController createFromGlobalConfiguratinWithTitle:self.title delegate:self];
}


-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	PhotoDetailView *photoImageView = (PhotoDetailView *)[photoImageViews objectAtIndex:selectedIndex];
	[photoImageView showCaptionView];
	[self presentImageViews];
    [self createAds];   
}


#pragma mark Scroll View methods
// --------------------------------------

- (void)scrollViewDidEndDecelerating:(UIScrollView *)theScrollView {
	DebugLog(@"end decelerating");
	float pageWidth = self.view.frame.size.width + 10.0;
	int newIndex = floor( (theScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	selectedIndex = newIndex;
	[self presentImageViews]; //this will prepare the next image views from cache.
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	// Switch the indicator when more than 50% of the previous/next page is visible
	float pageWidth = self.view.frame.size.width + 10.0;
	int newIndex = floor( (scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	//we will now prioritize the image download if it exists so that the one the user
	//is currently looking at will be downloaded.
	if(selectedIndex != newIndex){
		DebugLog(@"new selected index %i", newIndex);
		AppMakrURLDownload * urlDownload = [urlDownloads objectForKey:[NSNumber numberWithInt:selectedIndex]];
		//we should prioritize the operation so that the image your looking at become the #1 priority. 
		if (urlDownload && urlDownload.operation) {
			if( ![urlDownload.operation isFinished] && ![urlDownload.operation isExecuting] && ![urlDownload.operation isCancelled] ) {
				DebugLog(@"seting high priority for download %i", selectedIndex);
				[urlDownload.operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
			}
		}

	}
	[self.view bringSubviewToFront:scrollView];	
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
}
-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DebugLog(@"\n\n\n\n Photos VC - MEMORY WARNING !!!!\n\n\n");
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.theFeedService = nil;		
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}*/
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { 
	[self layoutPhotos];	
}

#pragma  mark Ads

-(void)adReceived
{  
    if(self.adsManager.view.superview == nil)
    {
        CGRect newScrollFrame = scrollView.frame;
        newScrollFrame.size.height -= 50;
        scrollView.frame = newScrollFrame;
        
        CGRect adFrame = CGRectMake(0, scrollView.frame.size.height, scrollView.frame.size.width, 50);
        self.adsManager.view.frame = adFrame;
        [self.view addSubview:self.adsManager.view];
    }
}

@end
