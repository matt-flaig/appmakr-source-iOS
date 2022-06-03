//
//  NSString+XMLEntities.h
//  MWFeedParser
//
//  Created by Michael Waterfall on 11/05/2010.
//  Copyright 2010 Michael Waterfall. All rights reserved.
//

@interface NSString (XMLEntities)

// Instance Methods
- (NSString *)stringByStrippingTags;
- (NSString *)stringByDecodingXMLEntities;
- (NSString *)stringByEncodingXMLEntities;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)stringForJavaScript;

@end