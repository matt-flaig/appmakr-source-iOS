//
//  AbstractParser.h
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//
#import "TouchXML.h"
#import "FeedObjects.h"
#import "AppMakrDateTimeConvertor.h"

extern int maxEntries;

@class DataStore;
@interface AbstractParser : NSObject 
{
	NSObject *object;
	Feed * feed;
	CXMLDocument * doc;
    DataStore * objectStore;
	//int maxEntries;
	NSString * url;
	NSString * key;
	NSMutableSet * urlsOfEntries;
    AppMakrDateTimeConvertor* dtConvector;
}
@property (retain) NSString * url;
@property (retain) NSString * key;
@property (assign) Feed * feed;
@property (retain) CXMLDocument * doc;
@property (retain) DataStore * objectStore;

-(id) initWithDocument:(CXMLDocument *)newDoc id:(NSObject *)calledObject;
-(void) addObjectWithEntry:(Entry *)entry;
-(Link*) storeLinks:(CXMLElement *)propertyElement item:(NSMutableArray *)linksArray type:(Class)linkType;
-(void)storeHostName:(Link*) link;
-(Link*) createLinkFromXML:(CXMLElement*)propertyElement type:(Class)linkType;
-(Feed*) parse;

- (NSObject*) createObjectOfClass:(Class)aClass;
- (Entry*) createOrRetrieveEntryForFeedItem:(CXMLNode *)itemNode;
- (Entry*) createOrRetrieveEntryForFeedItem:(CXMLNode *)itemNode andFeedKey:(NSString *)feedKey;
- (Feed*) clearCashAndCreateFeed;
-(void) clearThumbnailsCache;
-(NSString*) guidForItemNode:(CXMLNode *)itemNode;
-(CXMLElement*) firstLinkHrefForItemNode:(CXMLNode *)itemNode;
-(NSString*) titleForItemNode:(CXMLNode *)itemNode;
-(NSString*) generateGuidFromNodeInfo:(CXMLNode *)itemNode;

-(void) adjustOrDeleteEntries;

@end
