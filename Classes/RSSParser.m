//
//  EventParser.m
//  politico
//
//  Created by PointAbout Dev on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RSSParser.h"
#import "TouchXML.h"
#import "Feed.h"
#import "Link.h"
#import "Entry.h"
#import "RegexKitLite.h"
#import "GeoParser.h"
#import "EntryLink.h"
#import "FeedLink.h"
#import "DataStore.h"
#import "NSString+url.h"

@implementation RSSParser

-(id) initWithDocument:(CXMLDocument *)theDoc id:(NSObject *)calledObject {
	if((self = [super initWithDocument:theDoc id:calledObject])) {
	}
	return self;
}

-(NSString *)guidForItemNode:(CXMLNode *)itemNode
{
	
	NSString * guid = nil;
	
	NSError * error = nil;
	
    NSDictionary *namespaceDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://purl.org/rss/1.0/", @"default", nil];
	NSArray * guidNodes = [itemNode nodesForXPath:@"./guid|./default:guid" namespaceMappings:namespaceDict error:&error];
	
	if ([guidNodes count] > 0) 
	{
		guid = [[guidNodes objectAtIndex:0] stringValue];
	}
	
	
	return guid;
	
}

-(CXMLElement *)firstLinkHrefForItemNode:(CXMLNode *)itemNode
{
	
	NSError * error = nil;
	
    NSDictionary *namespaceDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://purl.org/rss/1.0/", @"default", nil];
	NSArray * linkNodes = [itemNode nodesForXPath:@"./content|./default:content|./url|./default:url|./link|./default:link|./enclosure|./default:enclosure" 
                                
                                namespaceMappings:namespaceDict error:&error];

	if ([linkNodes count] > 0) 
	{
       return  (CXMLElement *)[linkNodes objectAtIndex:0];
    }
	
	return nil;
}

-(NSString *)titleForItemNode:(CXMLNode *)itemNode
{
	
	NSString * title = nil;
	
	NSError * error = nil;
	
    
    NSDictionary *namespaceDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://purl.org/rss/1.0/", @"default", nil];
    NSArray * titleNodes = [itemNode nodesForXPath:@"./title|./default:title" namespaceMappings:namespaceDict error:&error];
    
    if ([titleNodes count] > 0) 
	{
		title = [[titleNodes objectAtIndex:0]stringValue];
	}
	
	return title;
	
}


-(Feed *) parse 
{
	self.feed = [self clearCashAndCreateFeed]; 
    
    NSMutableArray * feedlinks = [[NSMutableArray alloc]init];

	
    NSError * error = nil;
	NSString *feedTitle;
	GeoParser * geoParser = [[[GeoParser alloc] init]autorelease];
	geoParser.objectStore = self.objectStore;
	
	CXMLElement * feedElement = [doc rootElement];
	
	DebugLog(@"attribute for name is %@", [[feedElement attributeForName:@"base"] stringValue] );
	feed.host = [[feedElement attributeForName:@"base"] stringValue];
	
	for (int m=0; m<MIN([[feedElement children] count],maxEntries); m++) {
		CXMLElement *feedChildElement = (CXMLElement *)[feedElement childAtIndex:m];
		if ([[feedChildElement name] isEqualToString:@"channel"]) {
			for (int n=0; n<[[feedChildElement children]count]; n++) {
                
                CXMLElement *channelChildElement = (CXMLElement *)[feedChildElement childAtIndex:n];
                if ([[channelChildElement name] isEqualToString:@"link"])  
                {
                
                    Link* link = [super storeLinks:channelChildElement item:feedlinks type:[FeedLink class]];
                    if(!feed.host)
                        [self storeHostName:link];
                }
			}
			for (int n=0; n<[[feedChildElement children]count]; n++) {
				CXMLElement *channelChildElement = (CXMLElement *)[feedChildElement childAtIndex:n];
				if ([[channelChildElement name] isEqualToString:@"title"] && [[feed host] rangeOfString:@"//twitter.com"].location != NSNotFound)  {
					feedTitle = [channelChildElement stringValue];
					NSArray *words = [feedTitle componentsSeparatedByString:@" / "];
					feedTitle = [words objectAtIndex:1];
				}
			}
		}
	}

    if (feedlinks) 
    {
        [feed addLinksFromArray:feedlinks];
	}
    [feedlinks release];
    feedlinks = nil;
    
    
    NSDictionary *namespaceDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://purl.org/rss/1.0/", @"default", nil];
    NSArray * itemsParsed = [doc nodesForXPath:@".//item|.//default:item" namespaceMappings:namespaceDict error:&error];
    
	for (int i=0; i<MIN([itemsParsed count],maxEntries); i++) 
	{
		CXMLElement *childElement = (CXMLElement *)[itemsParsed objectAtIndex:i];
		
		Entry * itemRSS = [self createOrRetrieveEntryForFeedItem:childElement andFeedKey:feed.key];
		itemRSS.order = [NSNumber numberWithInt:i];
        
        
        NSMutableArray * itemRSSlinks = nil;
        
        //DebugLog(@"%@",itemRSS.links);
        if (!itemRSS.links || ([itemRSS.links count] <= 0)) //Never update links. Only create them once
        {
            itemRSSlinks = [[NSMutableArray alloc]init];
        }
        
		
		for (int j=0; j<[[childElement children] count]; j++) 
		{
			CXMLElement *propertyElement = (CXMLElement *)[childElement childAtIndex:j];
			[geoParser parseGeoWithEntry:itemRSS xmlElement:propertyElement];
			
			if ([[propertyElement name] isEqualToString:@"title"]) 
			{
				itemRSS.title = [propertyElement stringValue];
			}
			//check for the prefix. otherwise if <media:description> appears after the <description> tag, the later one is stored
			else if ([[propertyElement name] isEqualToString:@"description"])  
			{
				if ( propertyElement.prefix != nil  && [propertyElement.prefix isEqualToString:@"media"] )
				{
					itemRSS.mediaSummary = [propertyElement stringValue];
				}
				else 
				{
					//first try the plain string value
					//DebugLog(@"string value is %@", propertyElement);
					itemRSS.summary = [propertyElement stringValue];
					//if the stringValue didn't have any text, attempt to get the XML string
					if (!itemRSS.summary) {
						itemRSS.summary = [propertyElement XMLStringWithOptions:CXMLTextKind];
					}
				}
				
			}
			else if ([[propertyElement name] isEqualToString:@"encoded"]) {
				//first try the plain string value
				itemRSS.content = [propertyElement stringValue];
				//if the stringValue didn't have any text, attempt to get the XML string
				if (!itemRSS.content) {
					itemRSS.content = [propertyElement XMLStringWithOptions:CXMLTextKind];
				}
			}
			else if ([[propertyElement name] isEqualToString:@"thumbnail"]) {
                NSString * thumbnailStr = [propertyElement stringValue];
				CXMLNode * urlNode = [propertyElement attributeForName:@"url"];
				if( urlNode ) {
					thumbnailStr = [urlNode stringValue];
				}
				itemRSS.thumbnailURL = [thumbnailStr correctUrlEncodedString];
			}
			else if([[propertyElement name] isEqualToString:@"content"] ||
					[[propertyElement name] isEqualToString:@"url"] ||
					[[propertyElement name] isEqualToString:@"link"] ||
					[[propertyElement name] isEqualToString:@"enclosure"])
			{
                if (itemRSSlinks) 
                {                    
                    Link * link = [super storeLinks:propertyElement item:itemRSSlinks type:[EntryLink class]];
                    if(!feed.host)
                        [self storeHostName:link];
                    
                    if ([[propertyElement name] isEqualToString:@"content"]) {
                        BOOL typePropertyPrefixEqualsImage = YES;
                        CXMLNode *typeNode = [propertyElement attributeForName:@"type"];
                        if (typeNode != nil) {
                            NSString *typeNodeString = [typeNode stringValue];
                            typePropertyPrefixEqualsImage =  [typeNodeString rangeOfString:@"image"].location == NSNotFound;
                        }
                        if ( (!typePropertyPrefixEqualsImage) ) {
                            itemRSS.fullSizedImageURL = link.href;
                        }
                    }
                }
			}
			
			else if ([[propertyElement name] isEqualToString:@"guid"])  {
				itemRSS.guid = [propertyElement stringValue];
			}
			
			else if ([[propertyElement name] isEqualToString:@"author"]) {
				if(!itemRSS.author) {
					itemRSS.author = [propertyElement stringValue];
					itemRSS.author = [[itemRSS.author stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					
					// Probably in the posterous namespace
					if([itemRSS.author isEqualToString:@""]) {
						for (int k=0; k<[[propertyElement children] count]; k++) {
							CXMLElement *posterousElement = (CXMLElement *)[propertyElement childAtIndex:k];
							if ([[posterousElement name] isEqualToString:@"nickName"]) {
								itemRSS.author = [posterousElement stringValue];
							}
							else if ([[posterousElement name] isEqualToString:@"displayName"]) {
								if(!itemRSS.author) {
									itemRSS.author = [posterousElement stringValue];
								}
							}
						}
					}
				}
			} 
			else if ([[propertyElement name] isEqualToString:@"creator"]) {
				if(!itemRSS.author)
					itemRSS.author = [propertyElement stringValue];
			} 
			else if ([[propertyElement name] isEqualToString:@"pubDate"] || 
					 [[propertyElement name] isEqualToString:@"date"]) {
					itemRSS.updated = [propertyElement stringValue];
			}
		}
		
		if([[feed host] rangeOfString:@"//twitter.com"].location != NSNotFound) {
			itemRSS.author = feedTitle;
		}
		
        if (itemRSSlinks) 
        {
            [itemRSS addLinksFromArray:itemRSSlinks];
           
		}
        
        [itemRSSlinks release];
        itemRSSlinks = nil;
        
		[super addObjectWithEntry:itemRSS];
			
	}
	
//	[self adjustOrDeleteEntries];
    [self clearThumbnailsCache];
	return feed;
}




@end