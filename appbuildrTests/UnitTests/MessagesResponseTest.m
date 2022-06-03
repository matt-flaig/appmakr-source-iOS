//
//  MessagesResponseTest.m
//  appbuildr
//
//  Created by akuzmin on 8/5/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "MessagesResponseTest.h"
#import "MessageViewController.h"

@implementation SendMessageViewControllerForTest
@synthesize bTestStatusCode;
- (void)messageWasSentAlert {    
}
- (void)messageWasNotSentAlert {
}
- (NSString *)getTextViewText {
    if (self.bTestStatusCode == true) {
        return @"";
    }
    else {
        return @"test text";
    }
}
@end

@implementation MessagesResponseTest

- (void) setUpClass {
    smVC = [[SendMessageViewControllerForTest alloc] init];
    [smVC viewDidLoad_SubmitButton];
}

- (void) tearDownClass {
    [smVC release];
    smVC = nil;
}

- (void) testSendMessageResponse {
    smVC.bTestStatusCode = true;
    [smVC requestFinishedWithStatusCode:200];
    GHAssertTrue(([smVC getSubmitButtonEnabledStatus]==false), @"submit button should be disabled after post message response status code 200");
    smVC.bTestStatusCode = false;
    [smVC requestFinishedWithStatusCode:501];
    GHAssertTrue(([smVC getSubmitButtonEnabledStatus]==true), @"submit button should be enabled after post message response status code 501");
}

@end
