//
//  AuthorizeViewController.h
//  appbuildr
//
//  Created by Fawad Haider  on 5/17/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterController.h"
#import "AppMakrSocializeService.h"
#import "Facebook.h"
//#import "SocializeServiceDelegate.h"
#import "AuthorizeTableViewCell.h"
#import "AuthorizeInfoTableViewCell.h"

#import <Socialize/Socialize.h>

@protocol AuthorizeViewDelegate

-(void)authorizationCompleted:(BOOL)success;

@end

@interface AuthorizeViewController : MasterController<UITableViewDelegate, UITableViewDataSource, FBSessionDelegate, FBRequestDelegate, AppMakrSocializeServiceDelegate, SocializeServiceDelegate> {
    UITableView                 *tableView;
    id<AuthorizeViewDelegate>   delegate;
    AppMakrSocializeService            *theService;
    NSString                    *_facebookUsername;
    //for unit test
    BOOL boolErrorStatus;
    
    //TEST
    Socialize *socialize;
    //
}

@property (nonatomic, retain) Socialize *socialize;
@property (nonatomic, retain) IBOutlet UITableView     *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<AuthorizeViewDelegate>)mydelegate;

//for unit test
- (NSObject *)checkErrorStatusCodeTestExecution;
- (AuthorizeInfoTableViewCell *)getAuthorizeInfoTableViewCell;
- (AuthorizeTableViewCell *)getAuthorizeTableViewCell;


@end
