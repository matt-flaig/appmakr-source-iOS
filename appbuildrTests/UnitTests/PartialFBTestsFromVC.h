//
//  PartialFBTestsFromVC.h
//  appbuildr
//
//  Created by akuzmin on 7/6/11.
//  Copyright 2011 pointabout. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 1

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
//#import "application_headers" as required

#import <OCMock/OCMock.h>
#import <GHUnitIOS/GHAsyncTestCase.h>

#import "CommentViewController.h"
#import "AppMakrProfileViewController.h"

@interface CommentUnitTestViewController : CommentViewController {

}
- (void)serviceAuthenticationWithThirdPartyCreds:(NSString*)vUserId;
@end

@interface AuthorizeUnitTestViewController : AuthorizeViewController {
}
- (AuthorizeInfoTableViewCell *)getAuthorizeInfoTableViewCell;
@end

@interface PartialFBTestsFromVC : GHAsyncTestCase {
    CommentViewController *controller_com;
    AuthorizeViewController *controller_auth;
    AppMakrProfileViewController *controller_prof;
}

@end
