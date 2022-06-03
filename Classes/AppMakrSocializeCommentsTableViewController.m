//
//  AppMakrSocializeCommentsTableViewController.m
//  appbuildr
//
//  Created by Fawad Haider on 12/2/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "AppMakrSocializeCommentsTableViewController.h"
#import "AppMakrCommentsTableViewCell.h"
#import	"EntryComment.h"
#import "NSDateAdditions.h"
#import "CommentViewController.h"
#import "appbuildrAppDelegate.h"
#import "AppMakrCommentsTableFooterView.h"
#import "UIView-AlertAnimations.h"
#import "AppMakrCommentDetailsViewController.h"
#import "AppMakrPostCommentViewController.h"
#import "PointAboutNavigationController+Socialize.h"
#import "AppMakrProfileViewController.h"
#import "UILabel-Additions.h"
#import "UIButton+Socialize.h"

#define UIColorFromRGB(rgbValue) [UIColor \
	colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
		green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
			blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppMakrSocializeCommentsTableViewController()
-(NSString*)getDateString:(NSDate*)date;
-(void)setupNavBar;
-(UIView*)prepareCommentsNavBarsLeftView;
-(UIBarButtonItem*) createLeftNavigationButtonWithCaption: (NSString*) caption;
@end

@implementation AppMakrSocializeCommentsTableViewController

@synthesize _tableView;
@synthesize brushedMetalBackground;
@synthesize backgroundView;
@synthesize roundedContainerView;
@synthesize noCommentsIconView;
@synthesize topToolBar;
@synthesize commentsCell;
@synthesize footerView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry*)myentry {
  
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry*) myentry commentDelegate:(id<SocializeCommentsDelegate>)myCommentDelegate
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        // Custom initialization
		_errorLoading = NO;
		_isLoading = YES;
		_observersAdded = NO;
        commentDelegate = myCommentDelegate;

		userImageDictionary = [[NSMutableDictionary alloc]initWithCapacity:20];;
		pendingUrlDownloads = [[NSMutableArray alloc]initWithCapacity:20];;

		_commentDateFormatter = [[NSDateFormatter alloc] init];
		[_commentDateFormatter setDateFormat:@"hh:mm:ss zzz"];

		_tableView.scrollsToTop = YES;
		_tableView.autoresizesSubviews = YES;

		self.view.clipsToBounds = YES;
		
		entry = [myentry retain];
            
		/* view inits for the error messages*/
		CGRect containerFrame = CGRectMake(0, 0, 140, 140);
		
		AppMakrTableBGInfoView * containerView = [[AppMakrTableBGInfoView alloc] initWithFrame:containerFrame bgImageName:@"socialize_resources/socialize-nocomments-icon.png"];

		containerView.hidden = YES;
		containerView.center = _tableView.center;

		[_tableView addSubview:containerView];
		informationView = containerView;
		informationView.errorLabel.text = @"No comments to show.";
		
		[self retainActivityIndicatorMiddleOfView];
	}
    return self;
}

- (UIView*)prepareCommentsNavBarsLeftView{
	NSArray* nibViews =  [[NSBundle mainBundle] loadNibNamed:@"commentsNavBarLeftItemView" owner:self options:nil];
	UIView* myview = [ nibViews objectAtIndex: 0];
	return myview;
}
	

-(void)setupNavBar{

    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Comments" style: UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    UIButton * cancelButton = [UIButton redSocializeNavBarButtonWithTitle:@"Close"];
	NSMutableArray* navButtonItems = [NSMutableArray arrayWithCapacity:3];

 	UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithCustomView:[self prepareCommentsNavBarsLeftView]];
	UIBarButtonItem* rightCancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
	UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	fixedSpace.width = 130;

	[navButtonItems addObject:leftItem];
	[navButtonItems addObject:fixedSpace];
	[navButtonItems addObject:rightCancelItem];
    self.topToolBar.tintColor = [UIColor blackColor];
	
	[self.topToolBar setItems:navButtonItems];
}

- (void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	if (!_observersAdded){
		
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liftMainViewWhenKeybordAppears:) name:UIKeyboardWillShowNotification object:nil];
        
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnMainViewToInitialposition:) name:UIKeyboardWillHideNotification object:nil];
		
        _observersAdded = YES;
	}
}

- (void)startFetchingComments{
	[commentDelegate startFetchingComments];
	_isLoading = YES;
}

- (void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	_observersAdded = NO;

    for(AppMakrURLDownload* pendingDownload in pendingUrlDownloads){
        pendingDownload.requestedObject = nil;
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
	UIImage * backgroundImage = [UIImage imageNamed:@"/socialize_resources/socialize-activity-bg.png"];
	UIImageView * imageBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	_tableView.backgroundView = imageBackgroundView; 
	[imageBackgroundView release];
		
}

#pragma mark tableFooterViewDelegate

-(IBAction)addCommentButtonPressed:(id)sender
{
    AppMakrPostCommentViewController * pcViewController = [[AppMakrPostCommentViewController alloc]init];
    pcViewController.delegate = self;
    
    PointAboutNavigationController * pcNavController = [PointAboutNavigationController socializeNavigationControllerWithRootViewController:pcViewController];
    
    
    [pcViewController release];
    [self presentModalViewController:pcNavController animated:YES];
}

#pragma mark -

#pragma mark CommentViewController delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


-(void)setEntry:(Entry *)myEntry{
	
	if (entry!= nil)
		[entry release];
	
	entry = myEntry;
	[entry retain];

	DebugLog(@" Entry Url  %@", entry.url );
	[self startFetchingComments];
	[self retainActivityIndicatorMiddleOfView];
	_errorLoading = NO;
	_isLoading = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	//CAAnimation * anim =[self.view.layer animationForKey:@"transform.scaleOut"];
	
	if (anim == [self.view.layer animationForKey:@"transform.scaleOut"]){
		[self.view.layer removeAnimationForKey:@"transform.scaleOut"];
		[self autorelease];
	}
	
	[self.view.layer removeAnimationForKey:@"transform.scaleOut"];
	[self.view removeFromSuperview];
	[self autorelease];
}
/*
-(void) didFetchComments:(NSArray *)comments error:(NSError *)error {
    [self releaseActivityIndicatorMiddleOfView];
    
    if (!error){
        
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO ]autorelease];
		_arrayOfComments = [comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
		_errorLoading = NO;
		_isLoading = NO;
		[_arrayOfComments retain];
		[_tableView reloadData];
        
    }
	else{
		_errorLoading = YES;
		_isLoading = NO;
		[_tableView reloadData];
        
	}
}
*/
-(void) /*socializeService:(SocializeService *)mysocializeService*/ didFetchCommentsForEntry:(Entry *)myentry error:(NSError *)error{

    [self releaseActivityIndicatorMiddleOfView];
   if (!error){

		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO ]autorelease];
		_arrayOfComments = [[entry.comments allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		entry = myentry;
	
		_errorLoading = NO;
		_isLoading = NO;
		[_arrayOfComments retain];
		[_tableView reloadData];
       
    }
	else{
		_errorLoading = YES;
		_isLoading = NO;
		[_tableView reloadData];
        
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	#ifdef 	SOCIALIZE_SERVICE_NOT_WORKING
		return 100;
	#else
	if ([_arrayOfComments count] <= 0 && !_isLoading) {
		[self addNoCommentsBackground];
	}
	else 
		[self removeNoCommentsBackground];
	
	if (_arrayOfComments)
		return [_arrayOfComments count];
	else
		return 0;
	#endif
}

-(NSString*)getDateString:(NSDate*)startdate{
	return [NSDate getTimeElapsedString:startdate]; 
}

-(UIBarButtonItem*) createLeftNavigationButtonWithCaption: (NSString*) caption
{
    UIButton *backButton = [UIButton blackSocializeNavBarBackButtonWithTitle:caption]; 
    [backButton addTarget:self action:@selector(backToCommentsList:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backLeftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    return backLeftItem;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_arrayOfComments count]){

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
		EntryComment* entryComment = ((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]);
        
        AppmakrCommentDetailsViewController* details = [[AppmakrCommentDetailsViewController alloc] init];
        details.title = [NSString stringWithFormat: @"%d of %d", indexPath.row + 1, [_arrayOfComments count]];
        details.entryComment = entryComment;
        
        UIBarButtonItem * backLeftItem = [self createLeftNavigationButtonWithCaption:@"Comments"];
        details.navigationItem.leftBarButtonItem = backLeftItem;	
        [backLeftItem release];
    
        [self.navigationController pushViewController:details animated:YES];
        [details release];
        
    }

}

-(IBAction)viewProfileButtonTouched:(id)sender
{
	NSInteger buttonIndex = ((UIButton *)sender).tag;
    EntryComment* entryComment = ((EntryComment*)[_arrayOfComments objectAtIndex:buttonIndex]);
    
    AppMakrProfileViewController * pvc = [[AppMakrProfileViewController alloc] initWithNibName:@"AppMakrProfileViewController" bundle:nil];
	pvc.userId = entryComment.userId;
    
	UIBarButtonItem * backLeftItem = [self createLeftNavigationButtonWithCaption:@"Comments"];
	pvc.navigationItem.leftBarButtonItem = backLeftItem;	
	[backLeftItem release];
	
	[self.navigationController pushViewController:pvc animated:YES];
	[pvc release];


}   
-(void)backToCommentsList:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
//TEST
- (UITableViewCell *)tableView:(UITableView *)newTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"socializecommentcell";
	AppMakrCommentsTableViewCell *cell = (AppMakrCommentsTableViewCell*)[newTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        // Create a temporary UIViewController to instantiate the custom cell.
        
        [[NSBundle mainBundle] loadNibNamed:@"AppMakrCommentsTableViewCell" owner:self options:nil];
        // Grab a pointer to the custom cell.
        cell = commentsCell;
        self.commentsCell = nil;
        
    }
	
#ifdef 	SOCIALIZE_SERVICE_NOT_WORKING
	cell.headlineLabel.text = @"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...";
	cell.summaryLabel.text = @"Stay Awesome!";
#else
	if ([_arrayOfComments count]){
        
		EntryComment* entryComment = ((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]);
		
		NSString *commentText = ((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).commentText;
		NSString *commentHeadline = ( (EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).username;// @"Anonymous";
        
        cell.locationPin.hidden = (entryComment.geoPoint == nil);
        cell.btnViewProfile.tag = indexPath.row;
		cell.headlineLabel.text = commentHeadline;
		[cell setComment:commentText];
		cell.dateLabel.text = [self getDateString:((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).date];
        
        
        CGRect cellRect = cell.bounds;
        CGRect datelabelRect = cell.dateLabel.frame;
        
        CGSize textSize = CGSizeMake(cellRect.size.width, datelabelRect.size.height);   //This is theoretical, the date text should never be the length of the cell.
        textSize = [cell.dateLabel.text sizeWithFont:cell.dateLabel.font constrainedToSize:textSize];
        
        
        
        CGFloat xLabelCoordinate = cellRect.size.width - textSize.width - 7;
        datelabelRect = CGRectMake(xLabelCoordinate, datelabelRect.origin.y, textSize.width, datelabelRect.size.height);
        cell.dateLabel.frame = datelabelRect;
        
        
        CGRect locationPinFrame = cell.locationPin.frame;
        CGFloat xPinCoordinate = xLabelCoordinate - locationPinFrame.size.width - 7;
        locationPinFrame = CGRectMake(xPinCoordinate, locationPinFrame.origin.y, locationPinFrame.size.width, locationPinFrame.size.height);
        
        cell.locationPin.frame = locationPinFrame;
		
        UIImage * profileImage =(UIImage *)[userImageDictionary objectForKey:entryComment.userImageURL];
		
		if (profileImage) 
		{
			cell.userProfileImage.image = profileImage;
		}
		else
		{
			cell.userProfileImage.image = [UIImage imageNamed:@"socialize_resources/socialize-cell-image-default.png"];
			if (([entryComment.userImageURL length] > 0))
			{ 
                AppMakrURLDownload* urlDownload =	[[AppMakrURLDownload alloc] initWithURL:entryComment.userImageURL sender:self 
                                                                                 selector:@selector(updateProfileImage:urldownload:tag:) 
                                                                                      tag:entryComment.userImageURL];
                
                [pendingUrlDownloads addObject:urlDownload];
                
			}
		}
	}
	else {
		if (_isLoading){
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Comments loading...";
			return cell;
		}
		else if (_errorLoading){
            
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Error retrieving comments";
			return cell;
            
		}
		else {
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Be the first commentator";
			return cell;
		}
	}
#endif
	return cell;
}
//
/*
- (UITableViewCell *)tableView:(UITableView *)newTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"socializecommentcell";
	AppMakrCommentsTableViewCell *cell = (AppMakrCommentsTableViewCell*)[newTableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
        // Create a temporary UIViewController to instantiate the custom cell.
        
        [[NSBundle mainBundle] loadNibNamed:@"AppMakrCommentsTableViewCell" owner:self options:nil];
        // Grab a pointer to the custom cell.
        cell = commentsCell;
        self.commentsCell = nil;
    
	   }
	
#ifdef 	SOCIALIZE_SERVICE_NOT_WORKING
	cell.headlineLabel.text = @"Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...";
	cell.summaryLabel.text = @"Stay Awesome!";
#else
	if ([_arrayOfComments count]){
		
		EntryComment* entryComment = ((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]);
        
        
		
		NSString *commentText = ((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).commentText;
		NSString *commentHeadline = ( (EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).username;// @"Anonymous";
        
        cell.locationPin.hidden = (entryComment.geoPoint == nil);
        cell.btnViewProfile.tag = indexPath.row;
		cell.headlineLabel.text = commentHeadline;
		[cell setComment:commentText];
		cell.dateLabel.text = [self getDateString:((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).date];
        
        
        CGRect cellRect = cell.bounds;
        CGRect datelabelRect = cell.dateLabel.frame;
        
        CGSize textSize = CGSizeMake(cellRect.size.width, datelabelRect.size.height);   //This is theoretical, the date text should never be the length of the cell.
        textSize = [cell.dateLabel.text sizeWithFont:cell.dateLabel.font constrainedToSize:textSize];
                    
        
        
        CGFloat xLabelCoordinate = cellRect.size.width - textSize.width - 7;
        datelabelRect = CGRectMake(xLabelCoordinate, datelabelRect.origin.y, textSize.width, datelabelRect.size.height);
        cell.dateLabel.frame = datelabelRect;
         
        
        CGRect locationPinFrame = cell.locationPin.frame;
        CGFloat xPinCoordinate = xLabelCoordinate - locationPinFrame.size.width - 7;
        locationPinFrame = CGRectMake(xPinCoordinate, locationPinFrame.origin.y, locationPinFrame.size.width, locationPinFrame.size.height);
        
        cell.locationPin.frame = locationPinFrame;
		
        UIImage * profileImage =(UIImage *)[userImageDictionary objectForKey:entryComment.userImageURL];
		
		if (profileImage) 
		{
			cell.userProfileImage.image = profileImage;
		}
		else
		{
			cell.userProfileImage.image = [UIImage imageNamed:@"socialize_resources/socialize-cell-image-default.png"];
			if (([entryComment.userImageURL length] > 0))
			{ 
                AppMakrURLDownload* urlDownload =	[[AppMakrURLDownload alloc] initWithURL:entryComment.userImageURL sender:self 
										selector:@selector(updateProfileImage:urldownload:tag:) 
											 tag:entryComment.userImageURL];

                [pendingUrlDownloads addObject:urlDownload];
 
			}
		}
	}
	else {
		if (_isLoading){
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Comments loading...";
			return cell;
		}
		else if (_errorLoading){

			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Error retrieving comments";
			return cell;

		}
		else {
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RegularCell"] autorelease];
			cell.textLabel.text = @"Be the first commentator";
			return cell;
		}
	}
#endif
	return cell;
}
*/
- (void) updateProfileImage:(NSData *)data urldownload:(AppMakrURLDownload *)urldownload tag:(NSObject *)tag 
{
	DebugLog(@"updating profile image from download callback");
	
	if (!_arrayOfComments)
		return;
	
	if (data!= nil) 
	{
		NSString * url = (NSString *)tag;
		DebugLog(@"Activity table cell URL: %@", url);
		
		UIImage *profileImage = [UIImage imageWithData:data];
        
        [pendingUrlDownloads removeObject:urldownload];
        
		[urldownload release];

		[userImageDictionary setObject:profileImage forKey:url];

		[_tableView reloadData];
	}
}


// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

#pragma -

#pragma mark UITableViewDelegate
// Display customization
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

// Variable height support
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [AppMakrCommentsTableViewCell getCellHeightForString:((EntryComment*)[_arrayOfComments objectAtIndex:indexPath.row]).commentText] + 50;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	return 80;
}
*/
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}
#pragma mark -


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dismissModalView:(UIView*)myView {

	[_modalViewController fadeOutView];
	[_modalViewController release];
}

-(void)dismissModalView:(UIView*)myView andPushNewModalController:(UIViewController*)newSocializeModalController{

	[_modalViewController release];
	_modalViewController =	(SocializeModalViewController *)[newSocializeModalController retain];
	((SocializeModalViewController*)_modalViewController).modalDelegate = self;
}

-(void) didPostCommentForEntry:(Entry *)myentry error:(NSError *)error{
	
    
	[self releaseActivityIndicatorMiddleOfView];
    
    AppMakrPostCommentViewController *pcvc = (AppMakrPostCommentViewController *) ((UINavigationController *) self.modalViewController).visibleViewController;
    
    [pcvc releaseActivityIndicatorMiddleOfView];
	
	[self.view setUserInteractionEnabled:YES];

	if (!error)
    {
		// do not do anything
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"date" ascending:NO ]autorelease];
		if (_arrayOfComments != nil)
			[_arrayOfComments release];

		_arrayOfComments = [[myentry.comments allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[_arrayOfComments retain];
		[self._tableView reloadData];
        [self dismissModalViewControllerAnimated:YES];
	
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

- (void)addNoCommentsBackground{

	informationView.errorLabel.hidden = NO;
	informationView.noActivityImageView.hidden = NO;
	informationView.hidden = NO;
}

- (void)removeNoCommentsBackground{
	informationView.errorLabel.hidden = YES;
	informationView.noActivityImageView.hidden = YES;
	informationView.hidden = YES;
}
#pragma mark TextView Delegate 

- (void)textViewDidChange:(UITextView *)textView {
	
}

#pragma mark PostCommentViewController Delegate

-(void)postCommentController:(AppMakrPostCommentViewController*) controller sendComment:(NSString*)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)shareLocation
{

    [controller retainActivityIndicatorMiddleOfView];
    [commentDelegate postComment:commentText location:commentLocation shareLocation:shareLocation];
	
}

-(void)postCommentControllerCancell:(AppMakrPostCommentViewController*) controller
{
    [controller releaseActivityIndicatorMiddleOfView];
    [self dismissModalViewControllerAnimated:YES];

}


#pragma mark FooterAnimateDelegate


#pragma mark -
- (void)dealloc {
    DebugLog(@"XXXX Deallocating the SocializeCommentsViewController XXXX %@", self);
    [pendingUrlDownloads removeAllObjects];
    [pendingUrlDownloads release];
    pendingUrlDownloads = nil;
	[informationView release];
	[entry release];
	[_arrayOfComments release];
	[userImageDictionary release];
	[_commentDateFormatter release];
    [footerView release];
    [super dealloc];
}

@end
