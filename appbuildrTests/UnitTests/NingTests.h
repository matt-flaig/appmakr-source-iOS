//
//  NingTests.h
//  appbuildr
//
//  Created by akuzmin on 8/3/11.
//  Copyright 2011 pointabout. All rights reserved.
//
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  Define USE_APPLICATION_UNIT_TEST to 0 if the unit test code is designed to be linked into an independent test executable.

#define USE_APPLICATION_UNIT_TEST 1

#import <OCMock/OCMock.h>
#import <GHUnitIOS/GHAsyncTestCase.h>
#import <UIKit/UIKit.h>
#import "NingDomainService.h"

@interface NingDomainServiceForUnitTest : NingDomainService {
}
//for unit test only
-(OAPointAboutASIFormDataRequest *)getActualRequest;
@end

@interface NingTests : GHAsyncTestCase {
    NingDomainServiceForUnitTest *domainService;
}

@end
