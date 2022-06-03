//
//  PartialFBTestsFromVC.m
//  appbuildr
//
//  Created by akuzmin on 7/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "PartialFBTestsFromVC.h"
#import "FacebookWrapper.h"

@implementation CommentUnitTestViewController

- (void)serviceAuthenticationWithThirdPartyCreds:(NSString*)vUserId {
    NSObject *vAccessToken = [OCMockObject niceMockForClass:[NSString class]];
    [theService authenticateWithThirdPartyCreds:vUserId accessToken:(NSString *)vAccessToken];
}

@end

@implementation AuthorizeUnitTestViewController

-(AuthorizeInfoTableViewCell *)getAuthorizeInfoTableViewCell
{
	static NSString *authorizeInfoTableViewCellId = @"authorize_info_cell";
	AuthorizeInfoTableViewCell *cell =(AuthorizeInfoTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:authorizeInfoTableViewCellId];
    
	if (cell == nil) 
	{
        cell = [[[AuthorizeInfoTableViewCell alloc] init] autorelease];
	}
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(AuthorizeTableViewCell *)getAuthorizeTableViewCell
{
	static NSString *profileCellIdentifier = @"authorize_cell";
    
	AuthorizeTableViewCell *cell =(AuthorizeTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
    
	if (cell == nil) 
	{
        cell = [[[AuthorizeTableViewCell alloc] init] autorelease];
	}
    return cell;
}

@end

@implementation PartialFBTestsFromVC

- (void) setUpClass {
    id mockAuthorizeViewDelegateObject = [OCMockObject niceMockForProtocol:@protocol(AuthorizeViewDelegate)];
    controller_auth = [[AuthorizeUnitTestViewController alloc] initWithNibName:nil bundle:nil delegate:mockAuthorizeViewDelegateObject];
    //
    controller_com = [[CommentUnitTestViewController alloc] init];
    //
    controller_prof = [[AppMakrProfileViewController alloc] initWithNibName:nil bundle:nil];
} 

- (void) tearDownClass {
    [controller_auth release];
    controller_auth = nil;
    //
    [controller_com release];
    controller_com = nil;
    //
    [controller_prof release];
    controller_prof = nil;
}

- (void)testProfileVCInitialization {
    GHAssertNotNil(controller_prof, @"AppMakrProfileViewController should be initialized after initWithNibName:bundle: method call");
}

- (void)testCommentVC_FBRequestDelegate_DidLoad {
    id fbRequestMock = [OCMockObject niceMockForClass:[FBRequest class]];
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    //test user id
    [resultDictionary setObject:@"AK" forKey:@"id"];
    //_isAuthRequest is needed to be YES
    [controller_com setVariablesForTest:YES];
    [controller_com request:(FBRequest *)fbRequestMock didLoad:resultDictionary];
    
    [resultDictionary release];
}

- (void)testUITableViewCellCreationMethodCalls {   
    //single cells methods testing
    GHAssertNotNULL([controller_auth getAuthorizeInfoTableViewCell], @"AuthorizeInfoTableViewCell cannot be nil");
    GHAssertNotNULL([controller_auth getAuthorizeTableViewCell], @"AuthorizeTableViewCell cannot be nil");
    //general method for cells testing
    
    NSObject *mockTableView = [OCMockObject niceMockForClass:[UITableView class]];
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
    GHAssertNotNULL([controller_auth tableView:(UITableView *)mockTableView cellForRowAtIndexPath:indexPath0], @"UITableViewCell cannot be nil");
    
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:1];
    GHAssertNotNULL([controller_auth tableView:(UITableView *)mockTableView cellForRowAtIndexPath:indexPath1], @"UITableViewCell cannot be nil");
}

- (void)testAuthorizeVC_WrongResponse {
    
    OCMockObject *socializeMock = [OCMockObject mockForClass:[AppMakrSocializeService class]];
    //can be any other code except 200 for this test
    NSInteger errorCode = 201;
    //can be any other name, just for error object creation
    NSString *errorDomain = @"ErrorDomain";
    //userInfo is not required
    NSError *error = [[NSError alloc] initWithDomain:errorDomain code:errorCode userInfo:nil];

    [controller_auth socializeService:(AppMakrSocializeService *)socializeMock didAuthenticateSuccessfully:YES error:error];
    
    [error release];
    
    GHAssertNotNULL([controller_auth checkErrorStatusCodeTestExecution], @"error code test object should not be NULL");
}

@end
