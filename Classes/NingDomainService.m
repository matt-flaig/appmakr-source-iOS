//
//  NingDomainService.m
//  appbuildr
//
//  Created by William M. Johnson on 9/12/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "NingDomainService.h"
#import "OAPointAboutASIFormDataRequest.h"
#import "OAPlaintextSignatureProvider.h"
#import "NSDictionary_JSONExtensions.h"

#define serviceProviderName @"Ning"

NSString * const NingLoginApi = @"NING_AUTHENTICATE";
NSString * const NingAddPhotoApi = @"NING_ADD_PHOTO";
NSString * const NingAddBlogPostApi = @"NING_ADD_BLOGPOST";
NSString * const NingUpdateStatusApi = @"NING_UPDATE_STATUS";
NSString * const NingGetUserInfoApi = @"NING_GET_USERINFO";



@implementation NingDomainService

@synthesize consumer;
@synthesize accessToken;
//@synthesize userIsLoggedin;
@synthesize delegate;

-(void)clearRequest
{
	@synchronized(self)
	{
		request.delegate = nil;
		[request cancel];
		[request release];
		request = nil;
	}
}
-(void) cancelRequest
{
	[self clearRequest];	
}
  
- (void) dealloc
{
	[self clearRequest];
	delegate = nil;
	[consumer release];
	[accessToken release];
	[subDomainName release];
	[author release];
	[super dealloc];
}

- (void) initOptioned {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * ningConsumerKey = [defaults objectForKey:@"NING_CONSUMER_KEY"];
    NSString * ningConsumerSecret = [defaults objectForKey:@"NING_CONSUMER_SECRET"];
    NSString * ningSubDomain = [defaults objectForKey:@"NING_SUBDOMAIN"];
    
    NSAssert((ningConsumerKey!=nil&& ([ningConsumerKey length]>0)), @"Invalid consumer key");
    NSAssert((ningConsumerSecret!=nil&& ([ningConsumerSecret length]>0)), @"Invalid consumer secret");
    NSAssert((ningSubDomain!=nil&& ([ningSubDomain length]>0)), @"Invalid Ning network (subdomain) name");
    subDomainName = [ningSubDomain retain];
    
    author=[[defaults objectForKey:@"NING_AUTHOR"] retain];
    
    self.consumer = [[OAConsumer alloc]initWithKey:ningConsumerKey secret:ningConsumerSecret];
    [self.consumer release];
    
    self.accessToken = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:serviceProviderName 
                                                                              prefix:subDomainName];
    [self.accessToken release];
    
    request = nil;
    
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		[self initOptioned];
	}
	return self;
}

-(NSString *)registrationUrlString
{

	NSString * regUlrStr = [NSString stringWithFormat:@"http://%@.ning.com",subDomainName];
	return regUlrStr;
}

-(NSURL *)fullURLforApi:(NSString *)api
{
	
	//The base API URL should be stored elsewhere so that it's easy to change later.
	NSString * fullURLString = [NSString stringWithFormat:@"https://external.ningapis.com/xn/rest/%@/1.0%@",subDomainName,api];
	return [NSURL URLWithString:fullURLString];
}

-(BOOL)userIsLoggedin
{
	
	NSAssert((self.consumer.key!=nil&& ([self.consumer.secret length]>0)), @"Invalid consumer key");
	NSAssert((self.consumer.secret!=nil&& ([self.consumer.secret length]>0)), @"Invalid consumer secret");
	
	return  (self.accessToken.key!=nil && self.accessToken.secret!=nil && ([self.accessToken.key length]>0) && ([self.accessToken.secret length]>0));
}

-(void) logout
{
	self.accessToken.key = @"";
	self.accessToken.secret = @"";
	[self.accessToken storeInUserDefaultsWithServiceProviderName:serviceProviderName prefix:subDomainName];	
}

-(void) startRequestAsync {
    [request startAsynchronous]; 
}

-(void) createRequestForLogin {
    NSURL *url = [self fullURLforApi:@"/Token?xn_pretty=true"];
    request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:url
														 consumer:self.consumer
															token:nil
															realm:nil
												signatureProvider:[OAPlaintextSignatureProvider new]];
}

-(void) loginWithUsername:(NSString *) username password:(NSString *) password
{
    [self createRequestForLogin];
    
	[ASIHTTPRequest clearSession];
	request.useCookiePersistence = NO;
	[request setUsername:username];
	[request setPassword:password];
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	
	
	request.requestNameTag = NingLoginApi;
	
	request.delegate = self;
	
	//[request startAsynchronous];
    [self startRequestAsync];
}

-(void) addPhoto:(UIImage *)photo title:(NSString *) photoTitle description:(NSString*) photoDescription
{
	//OAPointAboutASIFormDataRequest *request = nil;
	
//	NSURL *url = [NSURL URLWithString: @"https://external.ningapis.com/xn/rest/dcmomo/1.0/Photo?xn_pretty=true"];
	
	NSURL *url = [self fullURLforApi:@"/Photo?xn_pretty=true"];

	request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:url
														 consumer:self.consumer
															token:self.accessToken
															realm:nil
												signatureProvider:[OAPlaintextSignatureProvider new]];
	
	
	request.allowCompressedResponse = NO;
	request.requestMethod = @"POST";
	[request setPostValue:photoTitle forKey:@"title"];
	[request setPostValue:photoDescription forKey:@"description"];
	[request setTimeOutSeconds:40];
	
	NSData * imageData = UIImageJPEGRepresentation(photo, 1);
	[request setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"file"];
	
	
	request.requestNameTag = NingAddPhotoApi;
	request.delegate = self;
	[request startAsynchronous];
}
-(void) addBlogPost:(NSString*) blogPostContents title:(NSString *) blogPostTitle
{
	//OAPointAboutASIFormDataRequest *request = nil;
	  
	//NSURL *url = [NSURL URLWithString: @"https://external.ningapis.com/xn/rest/dcmomo/1.0/BlogPost"];
	
	NSURL *url = [self fullURLforApi:@"/BlogPost"];

	request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:url
														 consumer:self.consumer
															token:self.accessToken
															realm:nil
												signatureProvider:[OAPlaintextSignatureProvider new]];
	
	request.allowCompressedResponse = NO;
	request.requestMethod = @"POST";
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	
	[request setPostValue:blogPostTitle forKey:@"title"];
	[request setPostValue:blogPostContents forKey:@"description"];
	
	
	request.requestNameTag = NingAddBlogPostApi;
	request.delegate = self;
	
	[request startAsynchronous];
	
}

-(void) updateStatus:(NSString *)statusMessage
{
	//OAPointAboutASIFormDataRequest *request = nil;
	
	
	NSURL *url = [self fullURLforApi:@"/User"];

	
	request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:url
														 consumer:self.consumer
															token:self.accessToken
															realm:nil
												signatureProvider:[OAPlaintextSignatureProvider new]];
	
	request.allowCompressedResponse = NO;
	request.requestMethod = @"PUT";
	[request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
	
	[request setPostValue:statusMessage forKey:@"statusMessage"];
	
	request.requestNameTag = NingUpdateStatusApi;
	request.delegate = self;
	

	[request startAsynchronous];
	
	
	
}
-(void) getUserInformation
{
	//OAPointAboutASIFormDataRequest *request = nil;
	
	//NSString * urlString = [NSString stringWithFormat:@"https://external.ningapis.com/xn/rest/dcmomo/1.0/User?author=%@&fields=statusMessage,fullName,id,createdDate,iconUrl,email",author];
	//NSURL *url = [NSURL URLWithString:urlString];
	NSString * urlString = [NSString stringWithFormat:@"/User?author=%@&fields=statusMessage,fullName,id,createdDate,iconUrl",author];
	NSURL *url = [self fullURLforApi:urlString];
	request = [[OAPointAboutASIFormDataRequest alloc] initWithURL:url
														 consumer:self.consumer
															token:self.accessToken
															realm:nil
												signatureProvider:[OAPlaintextSignatureProvider new]];
	
	request.allowCompressedResponse = NO;
	request.requestMethod = @"GET";
	request.requestNameTag = NingGetUserInfoApi;
	request.delegate = self;
	
	
	[request startAsynchronous];
	
}


-(void) parseLoginInformation:(NSDictionary *)responseDictionary
{
	NSString *laccessToken = nil;
	NSString *laccessTokenSecret = nil;
	
	
	
	NSDictionary * entryDictionary = [responseDictionary objectForKey:@"entry"];
	laccessToken = [entryDictionary objectForKey:@"oauthToken"];
	laccessTokenSecret = [entryDictionary objectForKey:@"oauthTokenSecret"];
	author = [entryDictionary objectForKey:@"author"];
	[author retain];
	
	[[NSUserDefaults standardUserDefaults] setObject:author forKey:@"NING_AUTHOR"];
	
	
	self.accessToken =nil; 
	if (laccessToken && laccessTokenSecret) 
	{
		
		self.accessToken = [[OAToken alloc] initWithKey:laccessToken secret:laccessTokenSecret];
		[self.accessToken release];
	    [self.accessToken storeInUserDefaultsWithServiceProviderName:serviceProviderName prefix:subDomainName];
	}
	
}

- (void)requestFinished:(ASIHTTPRequest *)currentRequest
{
	
		NSString *responseBody = [[[NSString alloc] initWithData:[request responseData]
												   encoding:NSUTF8StringEncoding] autorelease];
		NSLog(@"%@", responseBody);
		
	
		OAPointAboutASIFormDataRequest * OArequest = (OAPointAboutASIFormDataRequest *) request;
		NSString * requestName = [OArequest.requestNameTag copy];
	
		NSError * error = nil;
	    NSDictionary * responseDictionary = [NSDictionary dictionaryWithJSONData:[OArequest responseData] error:&error];
	
	    if ([requestName isEqualToString:NingLoginApi]) 
		{
			[self parseLoginInformation:responseDictionary];
		}
	
		NSDictionary * serviceResponseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:requestName,@"type", responseDictionary, @"response",nil];
		[delegate serviceCallBack:serviceResponseDictionary];
		[requestName release];
		//[request release];
//	request = nil;
	
	[self clearRequest];
	
}
- (void)authenticationNeededForRequest:(ASIHTTPRequest *)currentRequest
{
	NSLog(@"athenticating");	
	[request cancelAuthentication];
}
- (void)requestFailed:(ASIHTTPRequest *)currentRequest
{
	NSString *responseBody = [[[NSString alloc] initWithData:[request responseData]
											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSLog(@"%@-%@->%@",[request.error localizedFailureReason],[request.error localizedDescription], responseBody);
	
	OAPointAboutASIFormDataRequest * OArequest = (OAPointAboutASIFormDataRequest *) request;
	NSString * requestName = [OArequest.requestNameTag copy];
	
	
	NSDictionary * serviceResponseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:requestName,@"type",request.error, @"error",nil];
	
	
	[delegate serviceCallBack:serviceResponseDictionary];
	[requestName release];
	//[request release];
//	request = nil;
	
	
	[self clearRequest];
}


@end
