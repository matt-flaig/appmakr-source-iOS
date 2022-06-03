//
//  NingTests.m
//  appbuildr
//
//  Created by akuzmin on 8/3/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "NingTests.h"
#import "OAPointAboutASIFormDataRequest.h"

@implementation NingDomainServiceForUnitTest

- (void) initOptioned {
    
    NSString * ningConsumerKey = @"fbdc4316-f542-4084-930a-17fb6c90ffcb";
    NSString * ningConsumerSecret = @"ee664728-a908-4b69-8dda-d32cb2d822bc";
    NSString * ningSubDomain = @"getsocialize";

    subDomainName = [ningSubDomain retain];
    
    author = [[NSString stringWithFormat:@"%@", @"some author"] retain];
    
    self.consumer = [[OAConsumer alloc] initWithKey:ningConsumerKey secret:ningConsumerSecret];
    [self.consumer release];
    
    self.accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"Ning" 
                                                                              prefix:subDomainName];
    [self.accessToken release];
    
    request = nil;
    
}

-(void) startRequestAsync {
    //do nothing: we do not want to use web
}

//for unit test only
-(OAPointAboutASIFormDataRequest *)getActualRequest {
    return request;
}
//

@end

@implementation NingTests

- (void) setUpClass {
    domainService = [[NingDomainServiceForUnitTest alloc] init];
    domainService.delegate = nil;
}

- (void) tearDownClass {
    [domainService release];
    domainService = nil;
}

- (void)testNingDomainServiceLoggingIn {
    [domainService loginWithUsername:@"qa@appmakr.com" password:@"b3s0cial"];
    [[domainService getActualRequest] prepare];
    
    NSString *strProperContent = @"oauth_consumer_key=fbdc4316-f542-4084-930a-17fb6c90ffcb&oauth_signature_method=PLAINTEXT&oauth_signature=ee664728-a908-4b69-8dda-d32cb2d822bc%26";
    NSString *strActualContent = [[domainService getActualRequest] getPostBodyContentPrefix];
    GHAssertTrue([strActualContent isEqualToString:strProperContent], @"Post data was not properly assembled");
}

@end
