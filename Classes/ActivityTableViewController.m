//
//  ActivityTableViewController.m
//  appbuildr
//
//  Created by Isaac Mosquera on 11/24/10.
//  Copyright 2010 pointabout. All rights reserved.
//
#define ROW_HEIGHT 61.0f

#import<math.h>

#import "ActivityTableViewController.h"
#import "Activity.h"
#import "EntryViewController.h"
#import "UILabel-Additions.h"
#import "AppMakrTableBGInfoView.h"
#import "AppMakrURLDownload.h"
#import <QuartzCore/QuartzCore.h>


@interface ActivityTableViewController()
-(void) configurateProfileImage:(UIImageView*)profileImageView;
@end

@implementation ActivityTableViewController

@synthesize showProfileImages;
@synthesize activityTableCell;
@synthesize activitiesArray;
@synthesize userImageDictionary;
@synthesize informationView;

- (void) dealloc
{
	[activitiesArray release];
	[userImageDictionary release];
	[informationView release];
	[super dealloc];
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad 
{
    [super viewDidLoad];

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.showProfileImages = YES;
	
//	UIImage * backgroundImage = [UIImage imageNamed:@"/socialize_resources/background_brushed_metal.png"];
//	UIImageView * imageBackgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
//	self.tableView.backgroundView =imageBackgroundView; 
//	[imageBackgroundView release];
	
	userImageDictionary = [[NSMutableDictionary alloc]initWithCapacity:20];;
	activitiesArray = nil;
	
	
	CGRect containerFrame = CGRectMake(0, 0, 140, 140);
	
	AppMakrTableBGInfoView * containerView = [[AppMakrTableBGInfoView alloc]initWithFrame:containerFrame  bgImageName:@"socialize_resources/socialize-noactivity-icon.png"];
	containerView.hidden = YES;
	containerView.center = self.tableView.center;
	[self.tableView addSubview:containerView];
	self.informationView = containerView;
	[containerView release]; 
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [activitiesArray count];
}

-(NSString *) timeString:(NSDate *)date
{
	NSString * formatString = @"%i%@";
	
	NSInteger timeInterval = (NSInteger) ceil(fabs([date timeIntervalSinceNow]));
	
	
	NSInteger daysHoursMinutesOrSeconds = timeInterval/(24*3600);
	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"d"]; 
	}
	
	daysHoursMinutesOrSeconds = timeInterval/3600;
	
	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"h"]; 
	}
	
	daysHoursMinutesOrSeconds = timeInterval/60;
	
	if (daysHoursMinutesOrSeconds > 0) 
	{
		return [NSString stringWithFormat:formatString,daysHoursMinutesOrSeconds, @"m"]; 
	}
	
	return [NSString stringWithFormat:formatString,timeInterval, @"s"];
}

// Customize the appearance of table view cells.

-(UIImage*)getActivityImage:(Activity*)activity{
    return (UIImage *)[userImageDictionary objectForKey:activity.userSmallImageURL];
}

-(void) configurateProfileImage:(UIImageView*)profileImageView
{
    profileImageView.layer.cornerRadius = 3.0;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = 1.0;
    
    UIView* shadowView = [[UIView alloc] init];
    shadowView.layer.cornerRadius = 3.0;
    shadowView.layer.shadowColor = [UIColor colorWithRed:22/ 255.f green:28/ 255.f blue:31/ 255.f alpha:1.0].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadowView.layer.shadowOpacity = 0.9f;
    shadowView.layer.shadowRadius = 3.0f;
    [[profileImageView superview] addSubview:shadowView];
    [shadowView addSubview:profileImageView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

   static NSString *CellIdentifier = @"activity_cell";
   ActivityTableViewCell *cell = (ActivityTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
		[[NSBundle mainBundle] loadNibNamed:@"ActivityTableViewCell" owner:self options:nil];
				
		if (showProfileImages != YES) 
		{
			self.activityTableCell.profileView.hidden = YES;
			UIView * infoView = self.activityTableCell.informationView;
		    CGRect frame = infoView.frame;
			frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
			infoView.frame = frame;
		}
        [self configurateProfileImage:self.activityTableCell.profileImageView];
		cell = activityTableCell;
		self.activityTableCell = nil;
		
		UIImage * backgroundImage = [UIImage imageNamed:@"socialize_resources/socialize-cell-bg.png"];
		UIImageView * imageView = [[UIImageView alloc] initWithImage:backgroundImage];
		CGRect backgroundImageFrame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height+1);
		imageView.frame = backgroundImageFrame;
		cell.backgroundView = imageView;
		[imageView release];
	}
	cell.profileImageView.image = [UIImage imageNamed:@"socialize_resources/socialize-cell-image-default.png"];
	Activity *activity = (Activity *)[activitiesArray objectAtIndex:indexPath.row];
	if (showProfileImages && !activity.userImageDownloaded) 	
	{
        UIImage * profileImage =(UIImage *)[userImageDictionary objectForKey:activity.userSmallImageURL];
		
		if (profileImage) 
		{
			activity.userProfileImage = profileImage;
			activity.userImageDownloaded = YES;
		}
		else
		{
			if (([activity.userSmallImageURL length]>0))
			{ 
				[[AppMakrURLDownload alloc] initWithURL:activity.userSmallImageURL sender:self 
									selector:@selector(updateProfileImage:urldownload:tag:) 
										 tag:activity.userSmallImageURL];
			}
		    else 
			{
				activity.userImageDownloaded = YES;
			}
		}
	}
	
	NSString * nameAndHourString = [NSString stringWithFormat:@"%@ about %@ ago",activity.username, [self timeString:activity.date]];
	cell.nameLabel.text = nameAndHourString;
	cell.btnViewProfile.tag = indexPath.row;

	cell.activityTextLabel.text = activity.title;
	cell.commentTextLabel.text = activity.text;
	
	if (activity.userProfileImage !=nil)
	{
		cell.profileImageView.image = activity.userProfileImage;
	}
	
	switch (activity.type) 
	{
		case ACTIVITY_TYPE_LIKE:
			cell.activityIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-cell-icon-like.png"];
			break;
		case ACTIVITY_TYPE_COMMENT:
			cell.activityIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-cell-icon-comment.png"];
			break;
        case ACTIVITY_TYPE_SHARE_TWITTER:
			cell.activityIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-cell-icon-twitter.png"];
			break;
        case ACTIVITY_TYPE_SHARE_FACEBOOK:
			cell.activityIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-cell-icon-facebook.png"];
			break;
        case ACTIVITY_TYPE_SHARE_EMAIL:
			cell.activityIcon.image = [UIImage imageNamed:@"/socialize_resources/socialize-activity-cell-icon-share.png"];
			break;
		default:
			break;
	}

	
	
    return cell;
}

- (void) updateProfileImage:(NSData *)data urldownload:(AppMakrURLDownload *)urldownload tag:(NSObject *)tag 
{
	DebugLog(@"updating profile image from download callback");
	
	if (!activitiesArray)
		return;

	
	if (data!= nil) 
	{
		NSString * url = (NSString *)tag;
		DebugLog(@"Activity table cell URL: %@", url);
		
		UIImage *profileImage = [UIImage imageWithData:data];
		if(profileImage)
            [userImageDictionary setObject:profileImage forKey:url];
		[self.tableView reloadData];
	}
	
	[urldownload release];
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

- (void)viewWillDisappear:(BOOL)animated 
{
}

#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

    
}

-(IBAction)viewProfileButtonTouched:(id)sender
{
	NSInteger buttonIndex = ((UIButton *)sender).tag;
	NSIndexPath * indexPath = [NSIndexPath indexPathForRow:buttonIndex inSection:0];
	
	[self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];

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



@end

