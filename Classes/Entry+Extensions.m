//
//  Entry+Extensions.m
//  appbuildr
//
//  Created by William Johnson on 10/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Entry+Extensions.h"
#import "Feed.h"
#import "ImageReference+Extensions.h"
#import "NSString+XMLEntities.h"
#import "NSString+HTML.h"
#import "Link.h"
#import "Statistics.h"
#import "AppMakrDateTimeConvertor.h"

#define CHECK_STRING(str) str != nil ? str : @"" 

@implementation Entry(Extensions)
//@dynamic statistics;

+ (NSArray *)sortedArray:(NSArray *)arrayToSort
{
	
	NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc]initWithKey:@"order" ascending:YES ]autorelease];
	return [arrayToSort sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
}	
- (NSArray *)linksInOriginalOrder
{
	return [Entry sortedArray:[self.links allObjects]];
}

-(Link *) getMediaLink 
{
	
	for (Link * link in self.links)
	{
		if( link && link.type ) {
			NSRange videoRange = [link.type rangeOfString:@"video"];
			NSRange audioRange = [link.type rangeOfString:@"audio"];
			if( videoRange.location != NSNotFound || audioRange.location != NSNotFound ) {
				return link;
			}
		}
	}
	return nil;
}

-(NSString *) getDisplayContent 
{
    NSString *displayContentLocal = (self.content && ![self.content isEqualToString:@""]) ? self.content : (self.summary && ![self.summary isEqualToString:@""]) ? self.summary :self.title;
	return  displayContentLocal;
}



-(NSString *) toJavascript 
{
    
    NSString* entryUpdated = @"";
    if(self.updated)
    {
        AppMakrDateTimeConvertor* convertor = [[AppMakrDateTimeConvertor alloc]initWithDestinationFormat:@"EEE, d MMM yyyy"];
        NSString* updateDate = [convertor convertDateTimeString:self.updated];
        entryUpdated = updateDate ? updateDate : self.updated;
        [convertor release];
    }
    
	NSString* appmakrEntryJS = [NSString stringWithFormat: @"\
								appmakr_entry = new Object(); \
								appmakr_entry.guid=\"%@\";\
								appmakr_entry.title=\"%@\"; \
								appmakr_entry.author=\"%@\";\
								appmakr_entry.updated=\"%@\";\
								appmakr_entry.content=\"%@\";",
								
								CHECK_STRING(self.guid), CHECK_STRING([self.title stringForJavaScript]), CHECK_STRING(self.author), CHECK_STRING(entryUpdated), CHECK_STRING([[self getDisplayContent] stringForJavaScript]) ];
    
	return appmakrEntryJS;
}

-(NSString*) printJSobjectWithTitle:(NSString*) titleId author:(NSString*) authorId date: (NSString*) dateId content: (NSString*)contetId
{
    NSMutableString* jsObject = [[self toJavascript] mutableCopy];
    [jsObject appendFormat:@"\
            $(\"#%@\").html(appmakr_entry.title);\
            var authorStr = '';\
            if(appmakr_entry.author)\
                authorStr = 'By ' + appmakr_entry.author;\
            $(\"#%@\").html(authorStr);\
            var dateStr = '';\
            if(appmakr_entry.updated)\
                dateStr = 'on ' + appmakr_entry.updated;\
            $(\"#%@\").html(dateStr);\
            $(\"#%@\").html(appmakr_entry.content);",
     
            titleId, authorId, dateId, contetId
    ];
    return [jsObject autorelease];
}

-(NSString *) moduleType
{
	return self.feed.moduleType;	
}

- (void)didSave
{
	if ([self isDeleted]) 
	{
		[self.thumbnailImage deleteImage];
		[self.fullSizedImage deleteImage];
	}	
}

- (void)addLinksFromArray:(NSArray *)value
{
    for (int i = 0; i< [value count]; i++) {
        Link* link = (Link*)[value objectAtIndex:i];
        link.order = [NSNumber numberWithInt: i];
    }
    [self addLinks:[NSSet setWithArray:value]];
}

@end
