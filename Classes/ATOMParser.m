//
//  ATOMParser.m
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "ATOMParser.h"
#import "TouchXML.h"
#import "RegexKitLite.h"
#import "GeoParser.h"
#import "FeedLink.h"
#import "EntryLink.h"
#import "NSString+url.h"

@implementation ATOMParser

- (void) dealloc
{
	[namespaceDict release];
	[super dealloc];
}


-(id) initWithDocument:(CXMLDocument *)theDoc id:(NSObject *)calledObject 
{
	if((self = [super initWithDocument:theDoc id:calledObject])) 
	{
		namespaceDict = [[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.w3.org/2005/Atom", @"atom", nil] retain];
	}
	return self;
}

-(NSString *)guidForItemNode:(CXMLNode *)itemNode
{
	
	NSString * guid = nil;
	
	
	NSError * error = nil;
	
	NSArray * guidNodes = [itemNode nodesForXPath:@"./atom:id" namespaceMappings:namespaceDict error:&error];
	
	if ([guidNodes count] > 0) 
	{
		guid = [[guidNodes objectAtIndex:0]stringValue];
	}
	
	return guid;
	
}
-(CXMLElement *)firstLinkHrefForItemNode:(CXMLNode *)itemNode
{
	
	NSError * error = nil;
	
	NSArray * linkNodes = [itemNode nodesForXPath:@"./atom:link|./atom:enclosure" namespaceMappings:namespaceDict error:&error];	
	
	if ([linkNodes count] > 0) 
	{
		return (CXMLElement *)[linkNodes objectAtIndex:0];
	}
	
	return nil;
}

-(NSString *)titleForItemNode:(CXMLNode *)itemNode
{
	
	NSString * title = nil;
	
	NSError * error = nil;
	
	NSArray * titleNodes = [itemNode nodesForXPath:@"./atom:title" namespaceMappings:namespaceDict error:&error];	
	
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
    
	
	NSError* error;
	GeoParser * geoParser = [[[GeoParser alloc] init] autorelease];
	geoParser.objectStore = self.objectStore;
	
     
        CXMLElement * feedElement = [doc rootElement];
        for (int i=0; i<MIN([[feedElement children] count]-1,maxEntries); i++) 
        {
            CXMLElement *feedChildElement = (CXMLElement *)[feedElement childAtIndex:i];
            if ([[feedChildElement name] isEqualToString:@"link"])  
            {
                Link* link = [super storeLinks:feedChildElement item:feedlinks type:[FeedLink class]];
                if(!feed.host)
                    [self storeHostName:link];
                    
            }
        }
	
        DebugLog(@"!!! feed links from parse = %@ !!!", feedlinks);
        
        [super.feed addLinksFromArray:feedlinks];
        
    [feedlinks release];
    feedlinks = nil;
	
	//NSDictionary *namespaceDict = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.w3.org/2005/Atom", @"atom", nil];
	NSArray * itemsParsed = [doc nodesForXPath:@"./atom:feed/atom:entry" namespaceMappings:namespaceDict error:&error];
	for (int i=0; i<MIN([itemsParsed count],maxEntries); i++) {			
		
		CXMLElement *childElement = (CXMLElement *)[itemsParsed objectAtIndex:i];
		
		Entry * item = [self createOrRetrieveEntryForFeedItem:childElement andFeedKey:feed.key];
		item.order = [NSNumber numberWithInt:i];
		
		NSMutableArray * entrylinks = nil;
         
        if (!item.links || ([item.links count] <= 0)) //Never update links. Only create them once
        {
            entrylinks = [[NSMutableArray alloc]init];
        }
        
        for (int j=0; j<[[childElement children] count]; j++) {
			CXMLElement *propertyElement = (CXMLElement *)[childElement childAtIndex:j];
			[geoParser parseGeoWithEntry:item xmlElement:propertyElement];
			if ([[propertyElement name] isEqualToString:@"title"])  {
				item.title = [propertyElement stringValue];
			}
			else if ([[propertyElement name] isEqualToString:@"content"])  {
				//first try the			plain string value
				item.content = [propertyElement stringValue];
				if (item.content) {
					item.content = [item.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				}
				//if the stringValue didn't have any text, attempt to get the XML string
				if (!item.content || [item.content isEqualToString:@""]) {
					item.content = [propertyElement XMLStringWithOptions:CXMLTextKind];
				}
			} 
			else if ([[propertyElement name] isEqualToString:@"summary"])  {
				//first try the plain string value
				item.summary = [propertyElement stringValue];
				//if the stringValue didn't have any text, attempt to get the XML string
				if (!item.summary) {
					item.summary = [propertyElement XMLStringWithOptions:CXMLTextKind];
				}
			}
			else if ([[propertyElement name] isEqualToString:@"thumbnail"]) {
				NSString * thumbnailStr = [propertyElement stringValue];
				CXMLNode * urlNode = [propertyElement attributeForName:@"url"];
				if( urlNode ) {
					thumbnailStr = [urlNode stringValue];
					
				}
				item.thumbnailURL = [thumbnailStr correctUrlEncodedString];
			}
			else if([[propertyElement name] isEqualToString:@"link"] || [[propertyElement name] isEqualToString:@"enclosure"])
			{
                if (entrylinks) 
                {
                    
                    //TESTING BLOCK
                    BOOL relPropertyExists = [propertyElement attributeForName:@"rel"] != nil;
                    BOOL typePropertyExists = [propertyElement attributeForName:@"type"] != nil;
                    BOOL shouldLinkBeCreated = YES;
                    if (relPropertyExists && typePropertyExists) 
                    {
                        NSString *typeName = [[propertyElement attributeForName:@"type"] stringValue];
                        BOOL typePropertyPrefixEqualsImage = [typeName rangeOfString:@"image"].location != NSNotFound;
                        if (typePropertyPrefixEqualsImage) {
                            if (![[[propertyElement attributeForName:@"rel"] stringValue] isEqualToString:@"alternate"] && 
                                ![[[propertyElement attributeForName:@"rel"] stringValue] isEqualToString:@"image"] &&
                                ![[[propertyElement attributeForName:@"rel"] stringValue] isEqualToString:@"enclosure"]) {
                                shouldLinkBeCreated = NO;
                            }
                        }
                    }
                    
                    if (shouldLinkBeCreated) {
                    
                        //original code
                        Link * link = [super storeLinks:propertyElement item:entrylinks type:[EntryLink class]];
                        if(!feed.host)
                            [self storeHostName:link];
                    
                        if( [link hasMedia] ) 
                        {
                            //if its a content url, then it might be from flickr so we're going to store the url in the content field of the entry
                            item.fullSizedImageURL = link.href;
                        }
                        //
                    }
                    //
                }
			}
			else if ([[propertyElement name] isEqualToString:@"id"])  {
				item.guid = [propertyElement stringValue];
			}
			else if ([[propertyElement name] isEqualToString:@"author"]) {
				for (int k=0; k<[[propertyElement children] count]; k++) {
					CXMLElement *authorElement = (CXMLElement *)[propertyElement childAtIndex:k];
					if ([[authorElement name] isEqualToString:@"name"]) {
						item.author = [authorElement stringValue];
					}
				}
			}
			else if ([[propertyElement name] isEqualToString:@"updated"] || 
					 [[propertyElement name] isEqualToString:@"published"]) {
				if(!item.updated) {
					item.updated = [propertyElement stringValue];
				}
			}
		}
		
        if (entrylinks) 
        {
            [item addLinksFromArray:entrylinks];
            
        }
        
        [entrylinks release];
        entrylinks = nil;
        
		[super addObjectWithEntry:item];
	}
//	[self adjustOrDeleteEntries];
    [self clearThumbnailsCache];
	return feed;
}



@end
