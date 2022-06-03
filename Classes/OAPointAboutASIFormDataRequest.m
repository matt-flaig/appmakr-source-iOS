//
//  OAPointAboutASIFormDataRequest.m
//  appbuildr
//
//  Created by William M. Johnson on 9/10/10.
//  9-10-2010-William M. Johnson: Copied original "OAMutableURLRequest.m"
//  See copy right below.
//  
//  OAMutableURLRequest.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OAPointAboutASIFormDataRequest.h"
#import "NSURL+Base.h"
#import "NSString+URLEncoding.h"

@implementation NSURL (OABaseAdditions)

- (NSString *)URLStringWithoutQuery 
{
    NSArray *parts = [[self absoluteString] componentsSeparatedByString:@"?"];
    return [parts objectAtIndex:0];
}

@end


@implementation NSString (OAURLEncodingAdditions)

- (NSString *)URLEncodedString 
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
	return result;
}

- (NSString*)URLDecodedString
{
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8);
    [result autorelease];
	return result;	
}

@end


@interface OAPointAboutASIFormDataRequest (Private)
- (void)_generateTimestamp;
- (void)_generateNonce;
- (NSString *)_signatureBaseString;
@end

@implementation OAPointAboutASIFormDataRequest
@synthesize signature, nonce;
@synthesize requestNameTag;

#pragma mark init

- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider 
{
    if ((self = [super initWithURL:aUrl]))
	{    
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else 
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = [aProvider retain];
		
		[self _generateTimestamp];
		[self _generateNonce];
	}
    return self;
}

// Setting a timestamp and nonce to known
// values can be helpful for testing
- (id)initWithURL:(NSURL *)aUrl
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp 
{
	if ((self = [super initWithURL:aUrl]))
	{    
		consumer = [aConsumer retain];
		
		// empty token for Unauthorized Request Token transaction
		if (aToken == nil)
			token = [[OAToken alloc] init];
		else
			token = [aToken retain];
		
		if (aRealm == nil)
			realm = [[NSString alloc] initWithString:@""];
		else 
			realm = [aRealm retain];
		
		// default to HMAC-SHA1
		if (aProvider == nil)
			signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
		else 
			signatureProvider = [aProvider retain];
		
		timestamp = [aTimestamp retain];
		nonce = [aNonce retain];
	}
    return self;
}

- (void)dealloc
{
	[consumer release];
	[token release];
	[realm release];
	[signatureProvider release];
	[timestamp release];
	[nonce release];
	[extraOAuthParameters release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public

-(NSString*) encodedParamentrs
{
    NSString *encodedParameters = nil;
    
    if ([[self requestMethod] isEqualToString:@"GET"] || [[self requestMethod] isEqualToString:@"DELETE"]) 
        encodedParameters = [[self url] query];
	else 
	{
        // POST, PUT
        encodedParameters = [[[NSString alloc] initWithData:[self postBody] encoding:NSASCIIStringEncoding]autorelease];
    }
    return encodedParameters;
}

- (NSArray *)parameters 
{
    NSString *encodedParameters = [self encodedParamentrs];       
    if ((encodedParameters == nil) || ([encodedParameters isEqualToString:@""]))
        return nil;
    
    NSArray *encodedParameterPairs = [encodedParameters componentsSeparatedByString:@"&"];
    NSMutableArray *requestParameters = [[NSMutableArray alloc] initWithCapacity:16];
    
    for (NSString *encodedPair in encodedParameterPairs) 
	{
		
        NSArray *encodedPairElements = [encodedPair componentsSeparatedByString:@"="];
		
		if([encodedPairElements count] >= 2)
        {
            OARequestParameter *parameter = [OARequestParameter requestParameterWithName:[[encodedPairElements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
																			   value:[[encodedPairElements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [requestParameters addObject:parameter];
        }
	
    }
	
    return [requestParameters autorelease];
}

- (NSArray *)oauthParameters {
	NSMutableArray *parameterPairs = [NSMutableArray  arrayWithCapacity:(6 + [[self parameters] count])]; // 6 being the number of OAuth params in the Signature Base String
    
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" value:consumer.key] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" value:[signatureProvider name]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" value:timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" value:nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" value:@"1.0"] URLEncodedNameValuePair]];
    
    if (![token.key isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" value:token.key] URLEncodedNameValuePair]];
    }
    
	
	return parameterPairs;
}

- (NSString *)oauthParameterString 
{
	NSMutableArray *parameterPairs =(NSMutableArray *) [self oauthParameters];
	NSString *normalizedRequestParameters = [parameterPairs componentsJoinedByString:@"&"];
	return normalizedRequestParameters;
}

NSString* decodeFromPercentEscapeString(NSString *string) {
    return (NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue
{
	assert(parameterName && parameterValue);
	
	if (extraOAuthParameters == nil) {
		extraOAuthParameters = [NSMutableDictionary new];
	}
	//TEST
    //[extraOAuthParameters setObject:decodeFromPercentEscapeString(parameterValue) forKey:parameterName];
    //
	[extraOAuthParameters setObject:parameterValue forKey:parameterName];
}

- (void)prepare 
{
    // sign
	// Secrets must be urlencoded before concatenated with '&'
	// TODO: if later RSA-SHA1 support is added then a little code redesign is needed
	
	NSString * signatureBaseString = [self _signatureBaseString];
    signature = [signatureProvider signClearText:signatureBaseString
                                      withSecret:[NSString stringWithFormat:@"%@&%@",
												  [consumer.secret URLEncodedString],
                                                  [token.secret URLEncodedString]]];
  
	signature = [signature URLEncodedString];

    // set OAuth headers
    NSString *oauthToken;
    if ([token.key isEqualToString:@""])
        oauthToken = @""; // not used on Request Token transactions
    else
        oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [token.key URLEncodedString]];
	
	NSMutableString *extraParameters = [NSMutableString string];
	
	// Adding the optional parameters in sorted order isn't required by the OAuth spec, but it makes it possible to hard-code expected values in the unit tests.
	for(NSString *parameterName in [[extraOAuthParameters allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		[extraParameters appendFormat:@", %@=\"%@\"",
		 [parameterName URLEncodedString],
		 [[extraOAuthParameters objectForKey:parameterName] URLEncodedString]];
	}
		
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"",
                             [consumer.key URLEncodedString],
                             oauthToken,
                             [[signatureProvider name] URLEncodedString],
                             signature,
                             timestamp,
                             nonce];
    
    NSLog(@"%@", oauthHeader);

    if (self.username != nil) {
        //if making token request for ning: basic authentication should be transfered through 'Authorization' header and OAuth authentication parameters should be placed into post body
        //splited into two part for unit test only
        postBodyOAuthContentPrefix = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_signature_method=%@&oauth_signature=%@", [consumer.key URLEncodedString], [[signatureProvider name] URLEncodedString], signature];
        //@"oauth_consumer_key=%@&oauth_signature_method=%@&oauth_signature=%@&oauth_timestamp=%@&oauth_nonce=%@&oauth_version=1.0", [consumer.key URLEncodedString], [[signatureProvider name] URLEncodedString], signature, timestamp, nonce;
        NSString *postString = [NSString stringWithFormat:@"%@&oauth_timestamp=%@&oauth_nonce=%@&oauth_version=1.0", postBodyOAuthContentPrefix, timestamp, nonce];
        DebugLog(@"post body = %@", postString);
        [self appendPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        //if no basic authentication needed, OAuth parameters should be transfered trough 'Authorization' header
        [self addRequestHeader:@"Authorization" value:oauthHeader];
    }

    
 }

- (void)main
{
	[self prepare];
	[super main];
}

#pragma mark -
#pragma mark Private

- (void)_generateTimestamp 
{
    timestamp = [[NSString stringWithFormat:@"%d", time(NULL)] retain];
}

- (void)_generateNonce 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    nonce = (NSString *)string;
}


- (NSString *)_signatureBaseString 
{
    // OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
    // build a sorted array of both request parameters and OAuth header parameters
    NSMutableArray *parameterPairs =(NSMutableArray *) [self oauthParameters];
	
	for (OARequestParameter *param in [self parameters]) 
	{
        [parameterPairs addObject:[param URLEncodedNameValuePair]];
    }
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
	
	DebugLog(@"URL->%@",  [self url]);
	DebugLog(@"N ->%@", normalizedRequestParameters);
    
    // OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 [self requestMethod],
					 [[[self url] URLStringWithoutQuery] URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
	
	return ret;
}


- (void)setParameters:(NSArray *)parameters 
{
   NSMutableString *encodedParameterPairs = [NSMutableString stringWithCapacity:256];
    
    int position = 1;
    for (OARequestParameter *requestParameter in parameters) 
	{
        [encodedParameterPairs appendString:[requestParameter URLEncodedNameValuePair]];
        if (position < [parameters count])
            [encodedParameterPairs appendString:@"&"];
		
        position++;
    }
    
    if ([[self requestMethod] isEqualToString:@"GET"] || [[self requestMethod] isEqualToString:@"DELETE"])
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [[self url] URLStringWithoutQuery], encodedParameterPairs]]];
    else 
	{
        // POST, PUT
        NSData *localPostData = [encodedParameterPairs dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [self appendPostData:localPostData];
    }
}

//for unit test only
- (NSString *)getPostBodyContentPrefix {
    if (postBodyOAuthContentPrefix != nil) {
        return postBodyOAuthContentPrefix;
    }
    else {
        return @"";
    }
}

@end
