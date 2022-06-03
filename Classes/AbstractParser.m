//
//  AbstractParser.m
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "AbstractParser.h"
#import "DataStore.h"
#import "RegexKitLite.h"
#import "Link.h"
#import "NSString+HTML.h"
#import "GlobalVariables.h"
#import "DataStore.h"
#import "EntryImageReference.h"
#import "NSString+url.h"

int maxEntries;

@implementation AbstractParser
@synthesize feed;
@synthesize doc;
@synthesize objectStore;
@synthesize url;
@synthesize key;


+ (void)initialize
{
	NSDictionary* global = [GlobalVariables getPlist];
	NSDictionary* configuration = (NSDictionary * )[global objectForKey:@"configuration"];
	maxEntries = [[configuration objectForKey:@"max_stories"] intValue];
	
	if(!maxEntries)
		maxEntries = 100;
}

	
-(id) initWithDocument:(CXMLDocument *)newDoc id:(NSObject *)calledObject {
	if( (self = [super init]) ) {
		self.doc = newDoc;
		object = calledObject;
		
		urlsOfEntries = [[NSMutableSet setWithCapacity:30]retain];
	
		dtConvector = [[AppMakrDateTimeConvertor alloc]initWithDestinationFormat:@"EEE, d MMM yyyy h:mm:ss a"];
	}
	return self;
}

-(void) addObjectWithEntry:(Entry *)entry {
	
	//if there is no thumbnail set, search the content and summary for one to use
	//	if( !entry.thumbnail ) {
	
	//regex to find an image src
	NSString *regexString = @"<img.*?src=[\"'](.*?)[\"']"; 
	
	//use content first and then summary if no content exists
	//then remove new line and carriage return characters in case the img tag is split up over multiple lines
	NSString *imgSearchString = (entry.content && ![entry.content isEqualToString:@""]) ? entry.content : entry.summary;
	
	if([imgSearchString rangeOfString:@"tracking"].location == NSNotFound)// if not a tracking image, only then go ahead
	{
		imgSearchString = [imgSearchString stringByReplacingOccurrencesOfRegex:@"[\n\r]" withString:@""];
		
		NSArray *matchArray = [imgSearchString arrayOfCaptureComponentsMatchedByRegex:regexString]; 
		//NSArray *matchArray = [(entry.content && ![entry.content isEqualToString:@""]) ? entry.content : entry.summary arrayOfCaptureComponentsMatchedByRegex:regexString options:RKLMultiline range:NSMakeRange(0, [regexString length]) error:nil];
		if( [matchArray count] > 0 ) {
			NSString* imageUrl = (NSString* )[(NSArray *)[matchArray objectAtIndex:0] objectAtIndex:1];
			imageUrl = [imageUrl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if( ![imageUrl hasPrefix:@"http"] && [feed.links count] > 0 ) {
				entry.useHost = [NSNumber numberWithBool:YES];
				Link * link = [[feed linksInOriginalOrder] objectAtIndex:0];
				
				if( link ) {
					NSString * host = [[NSURL URLWithString:link.href] host];
					imageUrl = [NSString stringWithFormat:@"http://%@%@", host, imageUrl];
					//DebugLog(@"image url using feed.links is %@", imageUrl);
				}
			}
			else if( ![imageUrl hasPrefix:@"http"] ) {
				entry.useHost = [NSNumber numberWithBool:YES];
				imageUrl = [NSString stringWithFormat:@"http://%@%@", [feed host], imageUrl];
				//DebugLog(@"image url using entry.links is %@", imageUrl);
			}else {
				entry.useHost = [NSNumber numberWithBool:NO];
			}
			
			imageUrl = [imageUrl correctUrlEncodedString];
			if( !entry.thumbnailURL ) {
				entry.thumbnailURL = imageUrl;
			}
            if( !entry.fullSizedImageURL ) {
				entry.fullSizedImageURL = imageUrl;
			}
		}
	}
	

	if(!entry.thumbnailURL || !entry.fullSizedImageURL) {
        NSString* imageUrl = nil;
		for(Link *link in entry.links) {
			if(link.type && [link.type rangeOfString:@"image"].location != NSNotFound) {
				imageUrl = link.href;
			}	
		}
        entry.thumbnailURL = (entry.thumbnailURL == nil) ? imageUrl : entry.thumbnailURL;
        entry.fullSizedImageURL = (entry.fullSizedImageURL == nil) ? imageUrl : entry.fullSizedImageURL; 
	}
    
	if([[feed host] rangeOfString:@"search.twitter.com"].location != NSNotFound) {
		NSArray *words = [entry.author componentsSeparatedByString:@" ("];
		entry.title = [words objectAtIndex:0];
		words = [[words objectAtIndex:1] componentsSeparatedByString:@")"];
		entry.author = [words objectAtIndex:0];
		
		entry.type = @"twitterSearch";
	}
	else if([[feed host] rangeOfString:@"twitter.com"].location != NSNotFound) {
		entry.title = [entry.title stringByConvertingHTMLToPlainText];
		entry.title = [[[entry.title stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@" "] stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		entry.type = @"twitterUserTimeline";
	}
	else if(entry.title) {
		entry.title = [entry.title stringByConvertingHTMLToPlainText];
		entry.title = [[[entry.title stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@" "] stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	
	for(Link * link in entry.links)
	{
		if( link.href ) {
			link.href = [link.href stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
	}
	
	Link * link = nil;
	if( [entry.links count] > 0 ) 
	{   
		 link = [[entry linksInOriginalOrder] objectAtIndex:0];
	}
	
	if( !entry.guid ) 
	{
		
		if( link && link.href ) 
		{
				entry.guid = [link.href stringByAppendingString:entry.title];
		} 
		else 
		{
			entry.guid = entry.title;
		}
	}
	
	if( link && link.href ) 
	{ 
		entry.url = link.href;
	
	}
	else 
	{
		entry.url = entry.guid;
		
	}

	//Create a formatted description for the RootViewController's UITableViewCells
	if(entry.summary || entry.content)
	{
        entry.formattedDescription = entry.summary? [entry.summary stringByConvertingHTMLToPlainText] : [entry.content stringByConvertingHTMLToPlainText] ;
		entry.formattedDescription = [[[entry.formattedDescription stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@" "] stringByReplacingOccurrencesOfRegex:@"[\n\r\t]" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	if(!entry.formattedDescription || [entry.formattedDescription isEqualToString:@""] || [entry.formattedDescription isEqualToString:@"(null)"]) // No clean text is found so just use entry.author
	{
		entry.formattedDescription = entry.title;
	}
	if(!entry.formattedDescription || [entry.formattedDescription isEqualToString:@""] || [entry.formattedDescription isEqualToString:@"(null)"]) // No clean text is found so just use entry.author
	{
		entry.formattedDescription = entry.author;
	}
	
	if(entry.updated) {
        
        NSString *dateString = [dtConvector convertDateTimeString:entry.updated];
        if(dateString)
            entry.updated = dateString;
	}
	if( entry.mediaSummary ) {
		entry.mediaSummary = [entry.mediaSummary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else {
		entry.mediaSummary = entry.summary;
	}
    
    if(entry.thumbnailURL)
    {
        EntryImageReference* imageRef = (EntryImageReference*)[self.objectStore retrieveSingleEntityForClass:[EntryImageReference class] withValue:entry.thumbnailURL forAttribute:@"URLString"];
        entry.thumbnailImage = imageRef;
    }
    
	[self.feed addEntriesObject:entry];
	[urlsOfEntries addObject:entry.url];
	[object performSelector:@selector(feedParserIncrementProcessingProgress)];
}


-(NSString *)hrefForLinkElement:(CXMLElement *)propertyElement
{
    CXMLNode *hrefNode = [propertyElement attributeForName:@"href"];
	CXMLNode *urlNode = [propertyElement attributeForName:@"url"];  
    NSString * href = nil;
    
    href = [propertyElement stringValue];
	if( hrefNode ) {
		href = [hrefNode stringValue];
	}
	else if(urlNode) {
		href = [urlNode stringValue];
	}
	
	if( ![href hasPrefix:@"http:"] ) {
		href = [NSString stringWithFormat:@"%@%@", feed.host, href];
	}

    return  href;
}

-(Link*) createLinkFromXML:(CXMLElement*)propertyElement type:(Class)linkType
{
	Link * link = (Link *) [self createObjectOfClass:linkType];
	link.href = [[self hrefForLinkElement:propertyElement] correctUrlEncodedString];
    
   	CXMLNode *typeNode = [propertyElement attributeForName:@"type"];
	link.type = [typeNode stringValue];
	
    CXMLNode *titleNode = [propertyElement attributeForName:@"title"];
    link.title = [titleNode stringValue];
    
    CXMLNode *relNode = [propertyElement attributeForName:@"rel"];
    link.rel = [relNode stringValue];
    
    return link;
}

-(Link *)storeLinks:(CXMLElement *)propertyElement item:(NSMutableArray *)linksArray type:(Class)linkType
{
    Link* link = [self createLinkFromXML:propertyElement type:linkType];

    if(link)
    {	 
        if( link.rel && [link.rel isEqualToString:@"alternate"] ) 
        {
            [linksArray insertObject:link atIndex:0];
        }
        else 
        {
            [linksArray addObject:link];
        }
    }
    
    return link;
}

-(void)storeHostName:(Link*) link
{
	NSString *host = [[NSURL URLWithString:link.href] host];
	host = [NSString stringWithFormat:@"http://%@", host];
	feed.host = host;
}

-(Feed *)parse {
	//THIS METHOD IS ABSTRACT AND HAS NO IMPLEMENTATION
	return nil;
}

-(NSObject*) createObjectOfClass:(Class)aClass
{
	//return [[DataStore defaultStore] createObjectOfClass:aClass];
    return [objectStore createObjectOfClass:aClass];
}



-(NSString *)guidForItemNode:(CXMLNode *)itemNode
{
	return nil;	
}

-(CXMLElement *)firstLinkHrefForItemNode:(CXMLNode *)itemNode;
{
	
	return nil;
	
}
-(NSString *)titleForItemNode:(CXMLNode *)itemNode
{
	return nil;
}

-(NSString*) generateGuidFromNodeInfo:(CXMLNode *)itemNode
{
    NSString * guid = nil;
    
    CXMLElement * linkNode = [self firstLinkHrefForItemNode:itemNode];
    NSString *  linkHrefURL = [self hrefForLinkElement:linkNode];
    linkHrefURL = [linkHrefURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString * titleOfEntry = [self titleForItemNode: itemNode];
    
    if([linkHrefURL length] > 0)
    {
        guid = linkHrefURL;
        if([titleOfEntry length]>0)
        {
            guid = [linkHrefURL stringByAppendingString:titleOfEntry];
        }            
    }
    else
    {  
        guid = titleOfEntry;
    } 
    
    return guid;
}

- (Entry *) createOrRetrieveEntryForFeedItem:(CXMLNode *)itemNode andFeedKey:(NSString *)feedKey
{
	
	NSString * guid = [self guidForItemNode:itemNode];
	
	if( guid == nil ) 
	{
        guid = [self generateGuidFromNodeInfo: itemNode];
	}
    
    NSArray *entriesArray = [objectStore retrieveEntitiesForClass:[Entry class] withSortDescriptors:nil andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", guid]];
    Entry *entry = nil;
    if (entriesArray) {
        for (Entry *feedEntryItem in entriesArray) {
            if ([feedEntryItem.feed.key isEqualToString:feed.key]) {
                entry = feedEntryItem;
            }
        }
    }
    
	if (!entry) 
	{
        NSLog(@"creating new entry");
        entry = (Entry *) [self createObjectOfClass:[Entry class]];
	}
	
	return entry;
}

- (Entry *) createOrRetrieveEntryForFeedItem:(CXMLNode *)itemNode
{
	
	NSString * guid = [self guidForItemNode:itemNode];
	
	if( guid == nil ) 
	{
        [self generateGuidFromNodeInfo: itemNode];
	}
	
	Entry * entry = (Entry *)[objectStore retrieveSingleEntityForClass:[Entry class] withValue:guid forAttribute:@"guid"];
	
	if (!entry) 
	{
	  entry = (Entry *) [self createObjectOfClass:[Entry class]];
	}
	
	return entry;
}

- (Feed *) clearCashAndCreateFeed
{

	Feed * localFeed = (Feed *)[objectStore retrieveSingleEntityForClass:[Feed class] withValue:self.key forAttribute:@"key"];

	if(localFeed)
    {
        [objectStore deleteEntity:localFeed];
    }
    
    localFeed = (Feed *) [self createObjectOfClass:[Feed class]];
	localFeed.key = self.key;	
	localFeed.url = self.url;
	
	return localFeed;
}


- (void)adjustOrDeleteEntries
{
	
		NSPredicate * notInPredicate = [NSPredicate predicateWithFormat:@"NOT (url IN %@)", urlsOfEntries];
		NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"order" ascending:YES ]autorelease];	
		
	
		NSArray * entriesToAdjust = [[self.feed.entries filteredSetUsingPredicate:notInPredicate] 
									 sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
		
		//Add the old entries to the new feed and place them after the new feed's
		//original entries. This respects the maxStories.
		Entry *tempEntry = nil;
		int oldEntryCount = [entriesToAdjust count];
		int newEntryCount = [urlsOfEntries count];
			
		int j=0;
		for (; j < MIN(oldEntryCount,(maxEntries - newEntryCount)); j++)
		{
				tempEntry = (Entry *)[entriesToAdjust objectAtIndex:j];
				tempEntry.order = [NSNumber  numberWithInt:newEntryCount++];
				
		}
				 
		for(; j < oldEntryCount;j++)
		{
			tempEntry = (Entry *)[entriesToAdjust objectAtIndex:j];
			[self.feed removeEntriesObject:tempEntry];
			[objectStore deleteEntity:tempEntry];
		}
	
}

-(void)clearThumbnailsCache
{
    NSPredicate* oldThumbnailsPredicat = [NSPredicate predicateWithFormat:@"entry == nil"];
    NSArray* images = [self.objectStore retrieveEntitiesForClass:[EntryImageReference class] withSortDescriptors:nil andPredicate:oldThumbnailsPredicat];
    for (NSManagedObject* image in images) {
        [self.objectStore deleteEntity:image];
    }    
}

- (void) dealloc 
{
	[self.doc release];
	[urlsOfEntries release];
	[objectStore release];
    [dtConvector release];
	[super dealloc];
}


@end