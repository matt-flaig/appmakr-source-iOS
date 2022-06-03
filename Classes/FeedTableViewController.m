//
//  RootViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 1/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FeedTableViewController.h"
#import "EntryViewController.h"
#import "appbuildrAppDelegate.h"
#import "GlobalVariables.h"
#import "NetworkCheck.h"
#import "VarietyTableCell.h"
#import "RegexKitLite.h"
#import "MoviePlayerController.h"
#import "FeedDataSource.h"
#import "AppMakrUINavigationBarBackground.h"
#import "ImageReference+Extensions.h"
#import "SocializeModalViewCallbackDelegate.h"
#import "CommentViewController.h"
#import "LikeViewController.h"
#import "UIImage+Resize.h"
#import "CustomNavigationBar.h"
#import "SZPathBar.h"
#import "SZPathBar+Default.h"


@implementation FeedTableViewController

BOOL displayedErrorFromFeed = NO;
float navBarStartPosition = 20.0;

@synthesize tableView;
@synthesize viewTitle;
@synthesize bottomView;
@synthesize currentRow;
@synthesize changePageButton;
@synthesize mediaPlayerView;


- (void)dealloc 
{
	[editButton release];
	[changePageButton release];
	[tableView release];
	[bottomView release];
	[mediaPlayerView release];
	[super dealloc];
}
#pragma mark SocializeDelegate

-(void) socializeService:(AppMakrSocializeService *)socializeService didLikeEntry:(Entry *)entry error:(NSError *)error{

	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate releaseActivityIndicator];
	// disable view interaction while the message is being posted
	[self.view setUserInteractionEnabled:YES];

	/* start the liking view controller*/
	if (!error){
		LikeViewController *viewController = [[LikeViewController alloc]
												 initWithNibName:@"LikeViewController" bundle:nil];
		viewController.modalDelegate = self;
		[viewController fadeInView];
		_modalViewController = viewController; 
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
														message: [error localizedDescription]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"OK", @"")
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didPostCommentForEntry:(Entry *)entry error:(NSError *)error{

	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate releaseActivityIndicator];

	[self.view setUserInteractionEnabled:YES];
	if (!error){
		// do not do anything
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Failed!", @"") 
														message: [error localizedDescription]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"OK", @"")
											  otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
}

//-(void)commentButtonTouched:(Entry *)entry{
//
//	CommentViewController *viewController = [[CommentViewController alloc] 
//												initWithNibName:@"CommentViewController" bundle:nil];
//
//	viewController.modalDelegate = self;
//	viewController.entry = entry;
//	[viewController show];
//	_modalViewController = viewController; 
//}
//
//-(void)likeButtonTouched:(Entry *)entry{
//	// start the call to the feed service
//	[theFeedService likeEntry:entry];
//	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
//	[appDelegate retainActivityIndicator];
//	
//	// disable view interaction while the message is being posted
////	[self.view setUserInteractionEnabled:NO];
//}
//
//-(void)shareButtonTouched:(Entry*)entry{
//
//}

-(void)dismissModalView:(UIView*)myView andPostComment:(NSString*)comment forEntry:(Entry*)entry{
	[_modalViewController fadeOutView];
	[theFeedService postComment:comment forEntry:entry];

	// app builder delegate
	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
	[appDelegate retainActivityIndicator];
}

-(void)dismissModalView:(UIView*)myView {
	[_modalViewController fadeOutView];
	[_modalViewController release];
}

-(void)dismissModalView:(UIView*)myView andPushNewModalController:(UIViewController*)newSocializeModalController{
	[_modalViewController fadeOutView];
	[_modalViewController release];
	
	_modalViewController =	(SocializeModalViewController *)[newSocializeModalController retain];
	((SocializeModalViewController*)_modalViewController).modalDelegate = self;
	[_modalViewController show];
}

#pragma mark -

- (id)initWithFeed:(NSString* )feedUrl title:(NSString *)title {
	if ((self = [super initWithFeed:feedUrl title:title])) {		
		
	}
	return self;
}

- (void)tableView:(UITableView *)tableView didSwipeCellAtIndexPath:(NSIndexPath *)indexPath {
	
/*	NSString * path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	AVAudioPlayer * audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:path] error:nil];
	[audioPlayer play];
	[audioPlayer setDelegate:self];
	[audioPlayer addObject:audioPlayer];
	[audioPlayer release];
 */
	
}

- (void)viewDidLoad {

	self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
	self.view.autoresizesSubviews = YES;
	
	UITableView *listingTableView;
	listingTableView = [[[UITableView alloc] init] autorelease];
	self.tableView = listingTableView;

	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
	self.tableView.autoresizesSubviews = YES;
	self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	
	FeedDataSource * feedDataSource = [[FeedDataSource alloc] initWithFeedTableViewController:self] ;
	self.tableView.dataSource = feedDataSource;
	feedDataSource.archivePath = archivePath;

	self.tableView.rowHeight = 80;
	self.tableView.delegate = self;

	super._internalScrollView = self.tableView;
	[self.view addSubview:listingTableView];
	
	currentRow = -1;
	youtubeAtRoot = NO;
	feedAtRoot = NO;
	
	changePageButton = [[UISegmentedControl alloc] initWithItems:
						[NSArray arrayWithObjects:[UIImage imageNamed:@"up.png"], [UIImage imageNamed:@"down.png"], nil]];
	changePageButton.segmentedControlStyle = UISegmentedControlStyleBar;
	changePageButton.momentary = YES;
	changePageButton.frame = CGRectMake(110, 7, 100, 30);
	
	mediaPlayerView = [[UIView alloc]init];
	mediaPlayerView.hidden = YES;
	
	self.audioView = mediaPlayerView;
	[self.view addSubview:mediaPlayerView];
    
    if([GlobalVariables socializeEnable] && [GlobalVariables templateType] == AppMakrScrollTemplate)
    {
        bar = [[SZPathBar alloc] initWithButtonsMask: SZCommentsButtonMask|SZShareButtonMask|SZLikeButtonMask
                                parentController: (UIViewController*)self.pointAboutTabBarScrollViewController ? (UIViewController*)self.pointAboutTabBarScrollViewController: self
                                          entity: [SZEntity entityWithKey:rssFeedUrl name:feedKey]];
    
        [bar applyDefaultConfigurations];
  
        [self.view addSubview:bar.menu];
    }
    
	[super viewDidLoad];
}

- (void) loadView {
	[super loadView];
}

- (void)viewDidUnload {
	
	[super viewDidUnload];
	
	self.tableView = nil;
	self.mediaPlayerView = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[super scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//only refresh if the user has dragged the header up far enough
	[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)reloadTableViewDataSource {
	[self refreshEntries];
}

#pragma mark -
#pragma mark Millennial Ad View call backs

- (void)webLinkPressed {
	Entry * entry = [[self.feed entriesInOriginalOrder] objectAtIndex:currentRow];
	if ([NetworkCheck hasInternet] && [entry.links count] > 0) {
		Link * link = [[entry linksInOriginalOrder] objectAtIndex:0];
		[self gotoWebpageView: link.href];        
	}
}

- (void)feedPressed {
	Entry * entry = [[self.feed entriesInOriginalOrder]  objectAtIndex:currentRow];
	if ([NetworkCheck hasInternet] && [entry.links count] > 0) {
		Link * link = [[entry linksInOriginalOrder] objectAtIndex:0];
		[self gotoRootView: link.href];       
	}
}

- (void)gotoWebpageView:(NSString *)urlString {
	//DebugLog(@"link is: %@", urlString);
	Entry * entry = [[self.feed entriesInOriginalOrder]  objectAtIndex:currentRow];
	appbuildrAppDelegate* appDelegate =  (appbuildrAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.webpageController.entry = entry;
	appDelegate.webpageController.entryURL = urlString;	
	appDelegate.webpageController.parentController = @"root";
	//should we show the entry title in the header?
	if (entry.title && [[[GlobalVariables getPlist] objectForKey:@"display_details_title"] boolValue]) {
		appDelegate.webpageController.title = entry.title;
	}
	[self.navigationController.navigationBar setHidden:NO];
    
    if([self.navigationController.navigationBar isKindOfClass:[CustomNavigationBar class]])
    {
        [((CustomNavigationBar*)self.navigationController.navigationBar) clearBackground];
    }
    
	[[self navigationController] pushViewController:appDelegate.webpageController animated:YES];
	[appDelegate.webpageController showWebPageView];
}

- (void)gotoRootView:(NSString *)urlString {
	Entry * entry = [[self.feed entriesInOriginalOrder]  objectAtIndex:currentRow];
	NSString *entryTitle = [entry.title stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	
	FeedTableViewController *newRootViewController = [[FeedTableViewController alloc] initWithFeed:urlString title:entryTitle];
	newRootViewController.title = nil;
    newRootViewController.showTopImage = NO;
	[[self navigationController] pushViewController:newRootViewController animated:YES];
	[newRootViewController release];
}

#pragma mark table view delegate callbacks

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.theFeedService cancelAllFetchRequests];
    
    currentRow = [indexPath indexAtPosition: [indexPath length] - 1]; 
	if([feed.entries count] > 0)
	{
		[self pushDescriptionViewWithIndexPath:indexPath];
	}
	else
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) pushDescriptionViewWithIndexPath:(NSIndexPath *)indexPath {
	int storyIndex = [indexPath indexAtPosition: [indexPath length] - 1];
	Entry * entry = [[self.feed entriesInOriginalOrder]  objectAtIndex: storyIndex];
	
	if([entry.links count] > 0)
	{
		Link *link = (Link *)[[entry linksInOriginalOrder] objectAtIndex:0];
		
		if([link.href rangeOfString:@"youtube.com/watch"].location != NSNotFound)
		{
			youtubeAtRoot = YES;
			[self webLinkPressed];
		}
               
		else if(([link.type rangeOfString:@"application/rss"].location != NSNotFound ||
				 [link.type rangeOfString:@"application/rdf"].location != NSNotFound ||
				 [link.type rangeOfString:@"application/atom"].location != NSNotFound) && link.type)
		{
			feedAtRoot = YES;
			[self feedPressed];
		}
	}
	
	if(!youtubeAtRoot && !feedAtRoot)
	{
        EntryViewController* descController = [[EntryViewController alloc] initWithEntryID:entry.objectID];
        if(descController)
        {
            descController.modulePath = self.modulePath;
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:self.feedKey style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
            [self.navigationController pushViewController:descController animated:YES];
            [descController release];
        }
	}
	
	youtubeAtRoot = NO;
	feedAtRoot = NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	//DebugLog(@"accessory button was tapped");
	[self pushDescriptionViewWithIndexPath:indexPath];
}

- (void)tableView:(UITableView*)aTableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Remove";
}


// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations.
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated {	
	[super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
   	self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
	[self.tableView reloadData];
}



- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	DebugLog(@"MEMORY WARNING IN TABLE VIEWCONTROLLER");
}

#pragma mark -

#pragma mark FeedServiceDelegate implementation
- (void)feedService:(FeedService *)feedService didStartFetchingFeedForUrl:(NSURL *)feedUrl {
	
	[super feedService:feedService didStartFetchingFeedForUrl:feedUrl];
}

-(void) feedService:(FeedService *)feedService didFetchFeed:(Feed *)aFeed 
{		
	[super feedService:feedService didFetchFeed:aFeed];
}

-(void) feedService:(FeedService *)feedService didFailFetchingFeedWithError:(NSError *)error {
	[super feedService:feedService didFailFetchingFeedWithError:error];
	[self.tableView reloadData];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFetchStatisticsForEntries:(NSArray	*)entries error:(NSError *)error{

	[self.tableView reloadData];
}

-(void) feedServiceDidFinishFetchingFeed:(FeedService *)feedService 
{
	[super feedServiceDidFinishFetchingFeed:feedService];
	//TODO:: Remove due to deprecated service using
    //[theFeedService fetchStatisticsForEntries:[self.feed.entries allObjects]]; 
	[self.tableView reloadData];
}

-(void) socializeService:(AppMakrSocializeService *)socializeService didStartFetchingStatisticsForEntry:(Entry *)entry{

}

-(void) socializeService:(AppMakrSocializeService *)socializeService didFailFetchingStatisticsForEntry:(Entry *)entry withError:(NSError *)error{

}

-(void) socializeServiceDidFinishFetchingStatisticsForEntry:(Entry *)entry{

}

-(void) feedService:(FeedService *)feedService didFinishFetchingThumbnailForEntry:(Entry *)entry{
	
	// resize the image (will remove this later on)
	UIImage *thumbnailImage = [entry.thumbnailImage ImageObject];
	if( thumbnailImage && thumbnailImage.size.width > 30 && thumbnailImage.size.height > 30 ) {

		float desiredWidth;
		if([entry.type isEqualToString:@"twitterSearch"]) {
			desiredWidth = 48;
		}
		else {
			desiredWidth = 65;
		}
		
		thumbnailImage = [thumbnailImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
											 bounds:CGSizeMake( desiredWidth, desiredWidth)
							   interpolationQuality:kCGInterpolationDefault];
		
		if (thumbnailImage) 
		{
			[entry.thumbnailImage saveImage:thumbnailImage];
		}
	}
        
   
	
   NSUInteger storyIndex = [entry.order intValue];
	
	if (self.feed && ([self.feed.entries count] > storyIndex)) 
	{
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:storyIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
   
}

-(void) feedService:(FeedService *)feedService didFetchFullSizedImageForEntry:(Entry *)entry {
	
}

-(void) feedService:(FeedService *)feedService didFailFetchingFullSizedImageWithError:(NSError *)error {
	
}

-(void) feedServiceDidFinishFetchingFullSizedImage:(FeedService *)feedService {
	
}

-(void) OnConfigUpdate: (NSNotification*) notification
{
    [super OnConfigUpdate: notification];
    [self.tableView reloadData];
    
    NSString *name = self.title;
    if (name == nil) {
        // It's possible that the title may be set to nil by -[FeedViewController applyFeedUrl:title:]
        name = self.feedKey;
    }

    bar.entity = [SZEntity entityWithKey:rssFeedUrl name:name];
}
@end

