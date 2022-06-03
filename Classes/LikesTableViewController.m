//
//  LikesTableViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/30/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "LikesTableViewController.h"
#import "LikesTableViewCell.h"
#import "EntryViewController.h"
#import "appbuildrAppDelegate.h"
#import "UILabel-Additions.h"

@implementation LikesTableViewController
@synthesize likesFeed;
@synthesize socializeService;
@synthesize entriesArray;
@synthesize _tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	// awesome hack to remove the audio control from the top.
	self.title = @"Likes";
	self._tableView.delegate = self;
	self._tableView.dataSource = self;
	
	self._tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	/*UIImage * backgroundImage = [UIImage imageNamed:@"/socialize_resources/background_brushed_metal.png"];
	UIImageView * imageBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
	DebugLog(@"self.tableView   %@", self._tableView);
	DebugLog(@"self.view   %@", self.view);
	self._tableView.backgroundView = imageBackgroundView; 
	[imageBackgroundView release];*/
    

	/*Default no activity and error label inits  */
	CGRect containerFrame = CGRectMake(0, 0, 140, 140);
	AppMakrTableBGInfoView * containerView = [[AppMakrTableBGInfoView alloc]initWithFrame:containerFrame  bgImageName:@"/socialize_resources/socialize-nolikes-icon.png"];
	
	containerView.hidden = YES;
	containerView.center = self.view.center;
	[self.view addSubview:self._tableView];
	[self._tableView addSubview:containerView];
	informationView = containerView;
	informationView.errorLabel.text = @"You haven't liked anything.";
	[containerView release]; 
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar showCustomBackgroundImage];

//	appbuildrAppDelegate* appDelegate = (appbuildrAppDelegate *)[UIApplication sharedApplication].delegate;
//	[appDelegate unHideSocializeTabBar];
	
	AppMakrSocializeService * ss = [[AppMakrSocializeService alloc]init];
	ss.delegate = self;
	self.socializeService = ss;
	[ss release];
	
	[self updateLikesTableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	DebugLog(@"no of  entries %d", [self.entriesArray count]);
    return [self.entriesArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)mytableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"likes_view_cell";

    UITableViewCell *cell = [mytableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		NSArray *topLevelViews = [[NSBundle mainBundle] loadNibNamed:@"LikesTableViewCell" owner:self options:nil];
		for (id topLevelView in topLevelViews) {
			if ([topLevelView isKindOfClass:[LikesTableViewCell class]] ) {
				cell = (UITableViewCell *)[topLevelView retain];
				NSInteger index = indexPath.row;
				Entry *theEntry = (Entry *)[self.entriesArray objectAtIndex:index];
				[(LikesTableViewCell*)cell setupCellWithEntry:theEntry];
				break;
			}
		}
    }
    else {
		NSInteger index = indexPath.row;
		Entry *theEntry = (Entry *)[self.entriesArray objectAtIndex:index];
		[(LikesTableViewCell*)cell setupCellWithEntry:theEntry];
	}

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	NSInteger index = indexPath.row;
	Entry *theEntry = (Entry *)[self.entriesArray objectAtIndex:index];

	//EntryViewController* descController = [[EntryViewController alloc] 
	//									   initWithEntry:theEntry showMediaPlayer:NO];
	
	EntryViewController* descController = [[EntryViewController alloc] initWithEntryID:theEntry.objectID];
	
	
	[self.navigationController pushViewController:descController animated:YES];
	[descController release];
}

#pragma mark -

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[informationView release];
	[likesFeed  release];
	[socializeService  release];
	[entriesArray  release];
	[super dealloc];
}

#pragma mark -
#pragma mark SocializeService delegate Methods

/*
 download the user feed
*/

-(void) updateLikesTableView{
	
	self.entriesArray = [socializeService fetchLikedEntries];
	
	DebugLog(@"entriesArray count is %i", [entriesArray count]);
	if ([entriesArray count] <= 0) {
		if (informationView) {
			informationView.hidden = NO;
			informationView.noActivityImageView.hidden = NO;
			informationView.errorLabel.hidden = NO;
		}
	}
	else {
		informationView.hidden = YES;
		informationView.noActivityImageView.hidden = YES;
	}
	[self._tableView reloadData];
}

#pragma mark -

#pragma mark SocializeService delegate Methods for USER

//- (void)socializeServiceDidFetchLikesForUser: (SocializeService *)socializeService 


#pragma mark -


@end

