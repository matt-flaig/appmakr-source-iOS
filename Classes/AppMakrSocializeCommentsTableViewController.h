//
//  AppMakrSocializeCommentsTableViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 12/2/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"
#import "AppMakrSocializeService.h"
#import "SocializeModalViewController.h"
#import "MasterController.h"
#import "AppMakrCommentsTableFooterView.h"
#import	"AppMakrCommentsTableViewCell.h"
#import "AppMakrTableBGInfoView.h"
#import "AppMakrPostCommentViewController.h"


@protocol SocializeCommentsDelegate 

-(void)postComment:(NSString*)commentText location:(CLLocation *)commentLocation shareLocation:(BOOL)shareLocation;
-(void)startFetchingComments;

@end

@class AppMakrCommentsTableViewCell;

@interface AppMakrSocializeCommentsTableViewController : MasterController<UITableViewDataSource, SocializeModalViewCallbackDelegate, AppMakrPostCommentViewControllerDelegate> 
{

	IBOutlet UITableView	*_tableView;
	IBOutlet UIView			*backgroundView;
	IBOutlet UIImageView	*brushedMetalBackground;
	IBOutlet UIView			*roundedContainerView;
	IBOutlet UIImageView	*noCommentsIconView;
	IBOutlet UIToolbar		*topToolBar;
	
	Entry				*entry;
	NSArray				*_arrayOfComments;
	
	BOOL				_observersAdded;
	BOOL				_isLoading;
	BOOL				_errorLoading;
	NSDateFormatter     *_commentDateFormatter;

	SocializeModalViewController    *_modalViewController;
	AppMakrCommentsTableFooterView			*footerView;

	NSMutableDictionary             *userImageDictionary;
    NSMutableArray                  *pendingUrlDownloads;
	AppMakrTableBGInfoView                 *informationView; 
    id<SocializeCommentsDelegate>   commentDelegate;
    AppMakrCommentsTableViewCell *  commentsCell;
}

@property (retain, nonatomic) IBOutlet UITableView  *_tableView;
@property (retain, nonatomic) IBOutlet UIToolbar    *topToolBar;
@property (retain, nonatomic) IBOutlet UIImageView	*brushedMetalBackground;
@property (retain, nonatomic) IBOutlet UIView		*backgroundView;
@property (retain, nonatomic) IBOutlet UIView		*roundedContainerView;
@property (retain, nonatomic) IBOutlet UIImageView	*noCommentsIconView;
@property (nonatomic, assign) IBOutlet AppMakrCommentsTableViewCell *commentsCell;
@property (retain, nonatomic) IBOutlet AppMakrCommentsTableFooterView		*footerView;

-(IBAction)addCommentButtonPressed:(id)sender;
-(void)setEntry:(Entry *)myEntry;
-(void)addNoCommentsBackground;
-(void)removeNoCommentsBackground;
-(void)startFetchingComments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil entry:(Entry*) myentry commentDelegate:(id<SocializeCommentsDelegate>)myCommentDelegate;

-(void) /*socializeService:(SocializeService *)mysocializeService*/ didFetchCommentsForEntry:(Entry *)myentry error:(NSError *)error;
-(void) didPostCommentForEntry:(Entry *)myentry error:(NSError *)error;

//-(void) didFetchComments:(NSArray *)comments error:(NSError *)error;

-(IBAction)viewProfileButtonTouched:(id)sender;
@end
