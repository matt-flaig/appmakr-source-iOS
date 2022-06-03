//
//  SocializeServiceTests.h
//  appbuildr
//
//  Created by William Johnson on 12/6/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AppMakrSocializeService.h"

@class Feed;

@interface SocializeServiceTests : SenTestCase <AppMakrSocializeServiceDelegate>
{
	AppMakrSocializeService * socializeService;
	
	Feed * theFeed;
}

@property (nonatomic, retain) AppMakrSocializeService * socializeService;
@property (nonatomic, retain) Feed * theFeed;

//-(void)testSocialize;
/*-(void)testAuthentication;
-(void)testfetchStatistics;
-(void)testfetchComments;
-(void)testlikeEntry;
-(void)testviewEntry;
-(void)testPostComment;*/

@end
