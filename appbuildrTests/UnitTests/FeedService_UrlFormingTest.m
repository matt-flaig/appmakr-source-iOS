//
//  FeedService_UrlFormingTest.m
//  appbuildr
//
//  Created by akuzmin on 8/16/11.
//  Copyright 2011 pointabout. All rights reserved.
//

#import "FeedService_UrlFormingTest.h"

@implementation FeedServiceForTest

- (NSString *)fullSocializeApiURLString:(NSString *)api {
    return api;
}

@end

@implementation FeedService_UrlFormingTest

- (void) setUpClass {
    feedService = [[FeedServiceForTest alloc] init];
}

- (void) tearDownClass {
    [feedService release];
    feedService = nil;
}

- (void)testUrlStringFormat {
    NSString *strThatIs = [feedService fullURLStringforApi:@"someApiUrl" withQueryParameter:@"url=someUrl?w=300&#038;h=100&size=100&#038;ratio=fixed"];
    NSString *strThatShouldBe = @"someApiUrl?url=someUrl?w=300&h=100&size=100&ratio=fixed";
    BOOL isCorrectlyFormated = [strThatIs isEqualToString:strThatShouldBe];
    GHAssertTrue((isCorrectlyFormated==YES), @"Character entity reference should be removed from url string");
}

- (void)testUrlStringEncoding {
    //http://thebingoreview.files.wordpress.com/2011/04/logo.jpg?w=300&#038;h=137
    //url=http%3A%2F%2Fthebingoreview.files.wordpress.com%2F2011%2F04%2Flogo.jpg%3Fw%3D300%26h%3D137&size=100&ratio=fixed
    //url=http%3A%2F%2Fthebingoreview.files.wordpress.com%2F2011%2F04%2Flogo.jpg%3Fw%3D300%26h%3D137&size=960&ratio=fixed
    
    NSString *inputURL = @"http://thebingoreview.files.wordpress.com/2011/04/logo.jpg?w=300&#038;h=137";
    
    NSString *expectedURLStringForThumbnail = @"url=http%3A%2F%2Fthebingoreview.files.wordpress.com%2F2011%2F04%2Flogo.jpg%3Fw%3D300%26h%3D137&size=100&ratio=fixed";
    NSString *actualURLStringForThumbnail = [feedService getQueryURLForEntryThumbnail:inputURL];
    BOOL isCorrectlyFormated = [expectedURLStringForThumbnail isEqualToString:actualURLStringForThumbnail];
    GHAssertTrue((isCorrectlyFormated==YES), @"Wrong encoding format");
    
    NSString *expectedURLStringForFullSizedImage = @"url=http%3A%2F%2Fthebingoreview.files.wordpress.com%2F2011%2F04%2Flogo.jpg%3Fw%3D300%26h%3D137&size=960&ratio=fixed";
    NSString *actualURLStringForFullSizedImage = [feedService getQueryURLForEntryFullSizedImage:inputURL];
    isCorrectlyFormated = [expectedURLStringForFullSizedImage isEqualToString:actualURLStringForFullSizedImage];
    GHAssertTrue((isCorrectlyFormated==YES), @"Wrong encoding format");
}

@end
