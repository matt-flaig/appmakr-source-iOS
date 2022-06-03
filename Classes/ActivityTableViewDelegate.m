//
//  ActivityTableViewDelegate.m
//  appbuildr
//
//  Created by William Johnson on 12/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//
#import "ActivityTableViewDelegate.h"
#import "Activity.h"
#import "Entry.h"
#import "EntryViewController.h"
#import "AppMakrProfileViewController.h"
#import "UILabel-Additions.h"


#define ROW_HEIGHT 61.0f

@implementation ActivityTableViewDelegate
@synthesize activityController;

#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Activity *activity = (Activity *)[activityController.activitiesArray objectAtIndex:indexPath.row];
	
	switch(activity.type)
	{
		case ACTIVITY_TYPE_COMMENT:
			return (ROW_HEIGHT + 20);
			
		case ACTIVITY_TYPE_LIKE:
		default:
			return ROW_HEIGHT;
			
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.highlighted = NO;
	cell.selected = NO;
	
    Activity * act = [activityController.activitiesArray objectAtIndex:indexPath.row];
	
	Entry * entry = act.entry;
	
	EntryViewController* descController;
	if (entry)
	{
		//descController = [[EntryViewController alloc] 
		//									   initWithFeed:entry.feed storyIndex:storyIndex showMediaPlayer:NO];
		descController = [[EntryViewController alloc] initWithEntryID:entry.objectID];
						  
	}
//	else
//		descController = [[EntryViewController alloc] 
//											   initWithUrlString:act.url  showMediaPlayer:NO];
	
	[activityController.navigationController pushViewController:descController animated:YES];
	[descController release];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	
	Activity * act = [activityController.activitiesArray objectAtIndex:indexPath.row];
	
		
	AppMakrProfileViewController * pvc = [[AppMakrProfileViewController alloc] initWithNibName:@"AppMakrProfileViewController" bundle:nil];
	pvc.userId = act.userId;
	
	UIImage * backImageNormal = [[UIImage imageNamed:@"socialize_resources/socialize-button-back-bg.png"]stretchableImageWithLeftCapWidth:20 topCapHeight:0] ;
	UIImage * backImageHighligted = [[UIImage imageNamed:@"socialize_resources/socialize-button-back-hover-bg.png"]stretchableImageWithLeftCapWidth:20 topCapHeight:0];
	
	UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[backButton setBackgroundImage:backImageNormal forState:UIControlStateNormal];
	[backButton setBackgroundImage:backImageHighligted forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
	
	NSString * titleString = [NSString stringWithFormat:@"  %@", activityController.title];
	[backButton setTitle:titleString forState:UIControlStateNormal];
	[backButton addTarget:self action:@selector(editVCback:) forControlEvents:UIControlEventTouchUpInside];
	CGSize backButtonSize = [backButton.titleLabel.text sizeWithFont:backButton.titleLabel.font constrainedToSize:CGSizeMake(100, 29)];
	
    backButton.frame = CGRectMake(0, 0, backButtonSize.width+25, 29);

	[backButton.titleLabel applyBlurAndShadowWithOffset:-1.0];

	UIBarButtonItem * backLeftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
	pvc.navigationItem.leftBarButtonItem = backLeftItem;	
	[backLeftItem release];
	
	[activityController.navigationController pushViewController:pvc animated:YES];
	[pvc release];
	
}

-(void)editVCback:(id)button
{
	[activityController.navigationController popViewControllerAnimated:YES];
}

#pragma mark -


@end
