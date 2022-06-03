//
//  FeedParser.m
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "FeedParser.h"
#import "ATOMParser.h"
#import "RSSParser.h"
#import "TouchXML.h"
#import "NetworkCheck.h"
#import "Reachability.h"
#import "Link.h"
#import "RegexKitLite.h"
#import "DataStore.h"

@implementation FeedParser

@synthesize feedURL;
@synthesize feedKey;
@synthesize knownFeedLength;
@synthesize feedTotal;
@synthesize feedDone;
@synthesize objectStore;


+ (NSOperationQueue *)feedQueue {
	
	static NSOperationQueue *feedQueue;
    @synchronized(self)
    {
        if (!feedQueue) {
            feedQueue = [[NSOperationQueue alloc] init];
            [feedQueue setMaxConcurrentOperationCount:2];
        }
    }
	return feedQueue;
}

-(id)initWithData:(NSMutableData *)data {
    if (self == [super init]) {
		
		itemsData = [data retain];
	}
	return self;
}

-(id)initWithURL:(NSString *)URL id:(NSObject *)calledObject {
	
	if (self == [super init]) {
		object = calledObject;
		feedURL = [[URL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		feedURL = [[feedURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		//since utf8 didn't work we'll try Latin1
		if(!feedURL)
		{
			feedURL = [[URL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
			feedURL = [[feedURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
		}
		//since Latin1 didn't work we'll try ASCII
		if(!feedURL)
		{
			feedURL = [[URL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
			feedURL = [[feedURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		}
	}	
	return self;
}



-(void) parse 
{
	DebugLog(@"starting to download and parse");
	[object performSelectorOnMainThread:@selector(feedParserStartedCallback:) withObject:self waitUntilDone:NO];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(parseInBackground:) object:feedURL];
	[operation invocation];
	[[FeedParser feedQueue] addOperation:operation]; 
	[operation release];
}

-(void) parseInBackground:(NSString *)feed {
	DebugLog(@"parsing in background %@", feed);

	itemsData  = [[NSMutableData alloc] init];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:feed] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
	[request addValue:@"AppMakr Native i-Phone App Feed Reader 1.0" forHTTPHeaderField:@"User-Agent"];

	[NSURLConnection connectionWithRequest:request delegate:self];

	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]; ///??? we are waiting for 10 sec here???? is it true?
}

// called when you want to stop the timeout timer
- (void)cancelTimeoutCheck {
	[timeout invalidate];
	[timeout release];
	timeout = nil;
}

// called when you want to turn on the timeout timer.  intended to be called from didReceiveData (non-main thread) callback
- (void)enableTimeoutCheckForConnection:(NSURLConnection *)connection {
	
	timeout = [[NSTimer timerWithTimeInterval:20.0 target:self selector:@selector(timerFireMethod:) userInfo:connection repeats:NO] retain];
	
	// add to the mainRunLoop so that the timer doesn't get deleted when the didReceiveData callback run loop disappears
	[[NSRunLoop mainRunLoop] addTimer:timeout forMode:NSRunLoopCommonModes];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self cancelTimeoutCheck];
	[object performSelectorOnMainThread:@selector(feedParserProcessingCallback:) withObject:self waitUntilDone:YES];
	[self performSelector:@selector(startProcessingData) withObject:nil];
}

// timeout callback method
- (void)timerFireMethod:(NSTimer*)theTimer {
	NSURLConnection *connection = (NSURLConnection *)[theTimer userInfo];	
	[connection cancel];
	
	// take what we have downloaded and give it to the user
	[self connectionDidFinishLoading:connection];
	[timeout release];
	timeout = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self cancelTimeoutCheck];
	[itemsData appendData:data];
	feedDone = [itemsData length];
	if(object)
		[object performSelectorOnMainThread:@selector(feedParserLoadingCallback:) withObject:self waitUntilDone:YES];
	
	[self enableTimeoutCheckForConnection:connection];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DebugLog(@"receiving response");
	NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
	feedTotal = [[NSNumber numberWithLongLong:[response expectedContentLength]] floatValue];
	stringEncoding = NSUTF8StringEncoding;
	if( [httpResponse methodSignatureForSelector:@selector(allHeaderFields)] ) {
		NSDictionary * headers = [httpResponse allHeaderFields];
		NSString * contentType = [headers objectForKey:@"Content-Type"];
		if(object)
			[object performSelectorOnMainThread:@selector(feedParserLoadingCallback:) withObject:self waitUntilDone:YES];
		if( contentType ) {
			if( [contentType rangeOfString:@"UTF-8" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
				stringEncoding = NSUTF8StringEncoding;
			} else {
				stringEncoding = NSASCIIStringEncoding;
			}
		}
	}
	[self enableTimeoutCheckForConnection:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DebugLog(@"connection did fail with error!");
	[self cancelTimeoutCheck];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	//NSString * errorString = [NSString stringWithFormat:@"%@ (%i)",[error localizedDescription], [error code]];
	//DebugLog(@"error parsing XML: %@", errorString);
	[object performSelectorOnMainThread:@selector(feedParserDidEndWithError) withObject:nil waitUntilDone:YES];
}

-(Feed *)startProcessingData 
{
	NSError * error;
	CXMLDocument * doc = nil;
	
	NSString *docString = nil;
	
    //NOTE: empty feeds parsing problem(feed exists but has no items but has got not empty data)
    if ([itemsData length] < 75)
    {
        return nil;
    }
	
	docString = [[[NSString alloc] initWithData:[itemsData subdataWithRange:NSMakeRange(0,75)] encoding:NSUTF8StringEncoding] autorelease];
	NSString *regexString = @"<?xml.*?encoding=[\"'](.*?)[\"']"; 
	
	docString = [docString  stringByReplacingOccurrencesOfRegex:@"[\n\r]" withString:@""];
	NSArray *matchArray = nil;
	matchArray = [docString arrayOfCaptureComponentsMatchedByRegex:regexString]; 
	
	NSString *encoding = [[[NSString alloc] init] autorelease];
	if ([matchArray count]>0) {
		if ([[matchArray objectAtIndex:0] count] > 1) {
			encoding = [[matchArray objectAtIndex:0] objectAtIndex:1];
		}
	}
	
	
	if (encoding != NULL && ([encoding isEqualToString:@"UTF-8"] || [encoding isEqualToString:@"utf-8"])) {
		doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSUTF8StringEncoding options:CXMLDocumentTidyXML error:&error];  
		//	NSLog(@"doc is %@", doc);
		return [self parseDocument:[doc autorelease]];
	} 
	else if ( encoding != NULL && [[encoding lowercaseString] isEqualToString:@"iso-8859-1"] ) {
		doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSISOLatin1StringEncoding options:CXMLDocumentTidyXML error:&error];  
		//	NSLog(@"doc is %@", doc);
		return [self parseDocument:[doc autorelease]];
		
	}else if (encoding != NULL && [[encoding lowercaseString] isEqualToString:@"gb2312"] ){
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);   
        doc = [[CXMLDocument alloc] initWithData:itemsData encoding:enc options:CXMLDocumentTidyXML error:&error];  
        //	NSLog(@"doc is %@", doc);
        return [self parseDocument:[doc autorelease]];
    }
	else {
		
		NSString * utfEncodeTest = [[[NSString alloc]initWithData:itemsData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic)] autorelease];
        
        if ([utfEncodeTest length] > 0) {
            doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSUTF8StringEncoding options:CXMLDocumentTidyXML error:&error];

        } else if ( [utfEncodeTest rangeOfString:@"encoding=\"windows-1256\"" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
			doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSWindowsCP1251StringEncoding options:CXMLDocumentTidyXML error:&error];  
			
		}
		else {
			doc = [[CXMLDocument alloc] initWithData:itemsData encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsArabic) options:CXMLDocumentTidyXML error:&error];  
		}
		
		if ([doc childCount] == 0) {
			//since utf8 didn't work we'll try Latin1
			//DebugLog(@"using latin encoding");
			[doc release];
			doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSISOLatin1StringEncoding options:CXMLDocumentTidyXML error:&error];
		} 
		if ([doc childCount] == 0) {
			//since Latin1 didn't work we'll try utf16
			//DebugLog(@"trying NSUTF16StringEncoding (includes arabic characters)");
			[doc release];
			doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSUTF16StringEncoding options:CXMLDocumentTidyXML error:&error];
		}
		if([doc childCount] == 0) {
			//since utf16 didn't work we'll try ASCII
			//DebugLog(@"lastly, trying ascii");
			[doc release];
			doc = [[CXMLDocument alloc] initWithData:itemsData encoding:NSASCIIStringEncoding options:CXMLDocumentTidyXML error:&error];  
		}
		
		return [self parseDocument:[doc autorelease]];
		
	}
}

-(DataStore *)objectStore
{
   if (objectStore == nil) 
   {
	   objectStore = [[DataStore defaultStore]retain];
   }
   return objectStore;
}

-(Feed *)parseDocument:(CXMLDocument *)document{
	Feed *feed = nil;
	AbstractParser * parser = nil;
	
	CXMLElement * rootElement = [document rootElement];
	if( [[rootElement name] isEqualToString:@"feed"] ) 
	{
		parser = [[ATOMParser alloc] initWithDocument:document id:self];
	} 
	else 
	{
		parser = [[RSSParser alloc] initWithDocument:document id:self];
	}
	parser.url = self.feedURL;
	parser.key = self.feedKey;
	parser.objectStore = self.objectStore;
	feed = [parser parse];
	[parser release];
	DebugLog(@"feed parsed %i items, calling back object %@", [feed.entries count], object);
	[object performSelectorOnMainThread:@selector(feedParserDoneCallback:) withObject:feed waitUntilDone:YES];
	return feed;
}

-(void)feedParserIncrementProcessingProgress {
	[object performSelectorOnMainThread:@selector(feedParserIncrementProcessingProgress) withObject:nil waitUntilDone:YES];
}

- (void) dealloc 
{
	[objectStore release]; 
	[feedURL release];
	[feedKey release];
	[itemsData release];
	[super dealloc];
}

@end
