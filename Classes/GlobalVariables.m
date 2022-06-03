//
//  GlobalVariables.m
//  appbuildr
//
//  Created by PointAboutAdmin on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GlobalVariables.h"
#import "PropertiesList.h"
#import	"ASIHTTPRequest.h"
#import "Reachability.h"

#define OBSERVER_DID_CONFIGURATION_UPDATE @"did_update_configuration"
#define STAGE_SERVER_USERNAME @"appmakr"
#define STAGE_SERVER_PASSWORD @"Make@n@ppForThat"

@interface GlobalVariables()
-(NSString *)copyPlistToConfigurationDirectory;
-(BOOL)overWriteCurrentPlistWith:(NSDictionary *)newGlobalPlist;
+ (NSDictionary *)replaceWithContentsOfURL:(NSURL *)sourceURL;
+ (NSDictionary*)convertToDictionaryWithData:(NSData*)data;
+ (BOOL)persistWithNewDictionary:(NSDictionary*)newPListDictionary;
@end

@implementation GlobalVariables

@synthesize plist;

static GlobalVariables *globalVar;

- (id) init 
{
    self = [super init];
	if(self) 
	{
		globalVar.plist = [NSDictionary dictionaryWithContentsOfFile:[self copyPlistToConfigurationDirectory]];
		NSAssert((globalVar.plist!=nil),@"Error initializing global variables!" );		
	}
	return globalVar;
}

-(NSString *)copyPlistToConfigurationDirectory
{
	NSString * destinationPath = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	destinationPath = [[NSUserDefaults standardUserDefaults]valueForKey:@"global_plist"];
	
	if ([fileManager fileExistsAtPath:destinationPath]) 
	{
		return destinationPath;
	}
	
	NSError *error = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *configDirectory = [documentsDirectory stringByAppendingPathComponent:@"configuration"];
	
	BOOL success = YES;	
	
	if (![fileManager fileExistsAtPath:configDirectory]) 
	{
		success = [fileManager createDirectoryAtPath:configDirectory withIntermediateDirectories:FALSE 
							   attributes:nil error:&error];
	}
	
	
	NSString * sourcePath = [[NSBundle bundleForClass:self.class] pathForResource:@"global" ofType:@"plist"];
	if (success) 
	{
		destinationPath = [configDirectory stringByAppendingPathComponent:@"global.plist"];
		
	    [fileManager removeItemAtPath:destinationPath error:&error];
		success = [fileManager copyItemAtPath:sourcePath toPath:destinationPath error:&error];
		if (success) 
		{
			[[NSUserDefaults standardUserDefaults]setValue:destinationPath forKey:@"global_plist"];
			return destinationPath;
		}
	}
	
	return sourcePath;
}

-(BOOL) overWriteCurrentPlistWith:(NSDictionary *)newGlobalPlist
{
	NSString * destinationPath = nil;
	
	destinationPath = [[NSUserDefaults standardUserDefaults]valueForKey:@"global_plist"];
	
	if (destinationPath!=nil && ([destinationPath length]>1)) 
	{
		return [newGlobalPlist writeToFile:destinationPath atomically:YES];
	}
	return NO;
}

- (void)startUpdateWithDelegate:(id<GlobalVariablesDelegate>)delegate
{
	// return immediately if the web service cannot be reached  
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable){
		[delegate globalVarsUpdateCompleted];
		return;
	}
	
	// setting the delegate in to invoke when the data comes back successfully
	_delegate = delegate;
	
	NSString * appMakrHost = (NSString *)[[GlobalVariables getPlist] objectForKey:@"appmakr_host"];
	NSString * buildID = (NSString*) [[NSUserDefaults standardUserDefaults] valueForKey:@"build_number_preference"];
	NSString * plistUpdateUrl = [NSString stringWithFormat:@"%@/app_manager/edit_app/mashup/update_app_config/?build=%@"
								 ,appMakrHost
								 ,buildID];
	
	NSLog(@"Updating global plist from URL:%@.", plistUpdateUrl);
	NSURL *url = [NSURL URLWithString:plistUpdateUrl];  

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    if([appMakrHost isEqualToString:@"http://www.stage.appmakr.com"])
    {
        request.username = STAGE_SERVER_USERNAME;
        request.password = STAGE_SERVER_PASSWORD;
    }
    
	[request setDelegate:self];
	[request startAsynchronous];
	DebugLog(@"XXXX GlobalVariables startUpdateWithDelegate XXXX ");
}

#pragma mark ASI Delegates
- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching binary data
    DebugLog(@"XXXX GlobalVariables requestFinished XXXX ");
	[GlobalVariables persistWithNewDictionary:[GlobalVariables convertToDictionaryWithData:[request responseData]]];
	[_delegate globalVarsUpdateCompleted];
    
    NSNotification * notification = [NSNotification notificationWithName:OBSERVER_DID_CONFIGURATION_UPDATE object:globalVar];
	NSNotificationCenter * notificationCenter =  [NSNotificationCenter defaultCenter];
	[notificationCenter postNotification:notification];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    DebugLog(@"XXXX GlobalVariables requestFailed XXXX ");
	NSError *error = [request error];
	NSLog(@"Synching Global vars pList failed requestFailed --> %@", [error description]);
	[_delegate globalVarsUpdateCompleted];
}
#pragma mark -

+ (BOOL)persistWithNewDictionary:(NSDictionary*)newPListDictionary{
	
	BOOL success = NO;
	@synchronized(self)
	{
		if (newPListDictionary != nil) 
		{
			success = [globalVar overWriteCurrentPlistWith:newPListDictionary];
			if (success) 
			{
				globalVar.plist = newPListDictionary;
			}
		}
	}
	return success;
}

+(NSDictionary*)convertToDictionaryWithData:(NSData*)data{

	NSString *errorStr = nil;
	NSPropertyListFormat format;
	NSDictionary *propertyList = [NSPropertyListSerialization propertyListFromData:data
																  mutabilityOption:NSPropertyListImmutable
																			format:&format
																  errorDescription:&errorStr];
	[errorStr release];
	return propertyList;
}


+ (NSDictionary *)replaceWithContentsOfURL:(NSURL *)sourceURL
{
	@synchronized(self)
	{
		NSLog(@"Retrieving plist from URL->%@", sourceURL);
        NSDictionary * newPlistDictionary = [NSDictionary dictionaryWithContentsOfURL:sourceURL];
		if (newPlistDictionary != nil) 
		{
			BOOL success = [globalVar overWriteCurrentPlistWith:newPlistDictionary];
			if (success) 
			{
				globalVar.plist = newPlistDictionary;
			}
		}
    }
    return globalVar.plist;
}

+ (NSDictionary *)getPlist {
    @synchronized(self) {
        if (globalVar == nil) {
            globalVar = [[self allocWithZone:NULL] init] ; // assignment not done here
        }
    }
    return [[globalVar.plist retain] autorelease];
}

+ (GlobalVariables *)vars {
    @synchronized(self) {
        if (globalVar == nil) {
            globalVar = [[self allocWithZone:NULL] init] ; // assignment not done here
        }
    }
    return globalVar;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (globalVar == nil) {
            globalVar = [super allocWithZone:zone];
            return globalVar;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}
#pragma mark - helper functions

+(NSNumber *)buildID {
    NSDictionary* global = [GlobalVariables getPlist];
    NSNumber * build = (NSNumber *)[[global objectForKey:@"build"] objectForKey:@"pk"];
    return  build;
}
+(NSNumber *)appID {
    NSDictionary* global = [GlobalVariables getPlist];
    NSNumber * app = (NSNumber * )[[global objectForKey:@"application"] objectForKey:@"pk"];
    return app;
}

+(NSString *)appName
{
    NSDictionary* global = [GlobalVariables getPlist];
    NSString * app = [[global objectForKey:@"application"] objectForKey:@"display_name"];
    return app;
}

+(NSString *)appmakrHost {
    NSDictionary* global = [GlobalVariables getPlist];
    NSString* appmakrhost = (NSString * )[global objectForKey:@"appmakr_host"];
    return appmakrhost;
}
+(NSString *)socializeHost {
    NSDictionary* global = [GlobalVariables getPlist];
    return (NSString *)[global valueForKey:@"socialize_api_url"]; 
}

+(BOOL)hasGeoRssTabIn:(NSArray *)modules{
    BOOL hasGeoTab = NO;
	for( int i = 0; i < [modules count]; i++ ) {
		NSDictionary *module		= (NSDictionary *)[modules objectAtIndex:i];
		
		NSDictionary *fields = [module objectForKey:@"fields"];
		NSDictionary *moduleSettings = (NSDictionary *)[fields objectForKey:@"settings"];
		NSDictionary *settingsFields = (NSDictionary *)[moduleSettings objectForKey:@"fields"];
		NSString* tabType = [fields objectForKey:@"type"];
		
		
		if([[settingsFields objectForKey:@"include_location"] boolValue])
        {
            hasGeoTab = YES;
			break;
        }
		
		if ([tabType isEqualToString:@"georss"]) {
			hasGeoTab = YES;
			break;
		}
        
        NSArray* children = [[module objectForKey:@"extras"]objectForKey:@"children"];
        if([children count]>0 && [self hasGeoRssTabIn:children])
        {
            hasGeoTab = YES;
            break;           
        }
	}
    return hasGeoTab;
}

+(NSDictionary*) configsForModulePath: (ModuleIndexPath*) mPath
{
    DebugLog(@"---------%i ---- %i", mPath.moduleIndex.intValue, mPath.childIndex.intValue);
    
    NSDictionary* global = [GlobalVariables getPlist];
    NSArray* modules = (NSArray * )[global objectForKey:@"modules"];
    NSAssert([modules count]>0,@"It looks like the count of modules was changed. This is wrong behavior");
    if(mPath.childIndex == nil)
    {
        return [modules objectAtIndex:mPath.moduleIndex.intValue];
    }
    else
    {
        NSDictionary* parentModule = [modules objectAtIndex:mPath.moduleIndex.intValue];
        NSArray *children = [[parentModule objectForKey:@"extras"]objectForKey:@"children"];
        return [children objectAtIndex:mPath.childIndex.intValue];
    }
}

+(AppMakrTemplateStyle) templateType
{
    NSNumber* templateType = [[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"TemplateType"];
    if(!templateType)
        return AppMakrTabbarTemplate;
    
    return [templateType intValue];
}

+(AppMakrBackgroundStyle) backgroundStyle
{
    return [[[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"BackgroundType"] intValue];    
}

+(NSString*) helpUrl
{
    return [[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"support_url"];    
}

+(NSString*) aboutPageUrl
{
    return [[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"about_url"];    
}

+(BOOL) enableMainMenu
{
    return [[[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"enable_tool_drawer"] boolValue];    
}

+(BOOL) isPremiumApp
{
    return [[[[GlobalVariables getPlist] objectForKey:@"application"]objectForKey:@"premium_app"] boolValue];
}

#pragma mark notification
+(void) addObserver: (id) observer selector: (SEL) selector
{
    NSNotificationCenter * notificationCenter  = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:observer selector:selector name:OBSERVER_DID_CONFIGURATION_UPDATE object:nil];    
}

+(void) removeObserver: (id)observer
{
    NSNotificationCenter * notificationCenter  = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:observer];
}

#pragma mark message tab accessors

+(NSString*)serverName: (NSDictionary*) configs
{					
	return [[[[configs objectForKey:@"fields"] objectForKey:@"settings"] objectForKey:@"fields"] objectForKey:@"server"];
}

+(NSNumber*)portNumber: (NSDictionary*) configs
{
    return [[[[configs objectForKey:@"fields"] objectForKey:@"settings"] objectForKey:@"fields"] objectForKey:@"port"];
}

+(NSString*)username: (NSDictionary*) configs
{
    return [[[[configs objectForKey:@"fields"] objectForKey:@"settings"] objectForKey:@"fields"] objectForKey:@"username"];
}

+(NSString*)password: (NSDictionary*) configs
{
    return [[[[configs objectForKey:@"fields"] objectForKey:@"settings"] objectForKey:@"fields"] objectForKey:@"password"];
}

+(NSString*)adress: (NSDictionary*) configs
{
    return [[configs objectForKey:@"fields"] objectForKey:@"url"];
}

#pragma mark socialize configuration
+(BOOL)socializeEnable
{
    NSDictionary* application = (NSDictionary * )[ [GlobalVariables getPlist] objectForKey:@"application"];
    return [[application objectForKey:@"socialize_enabled"] boolValue];  
}

+(BOOL)enableSocialPush
{
    NSDictionary* application = (NSDictionary * )[ [GlobalVariables getPlist] objectForKey:@"application"];
    return [[application objectForKey:@"socialize_push_enabled"] boolValue];  
}

#pragma mark background stile helper

+(UIColor*)backgroundColor
{
    UIColor *bgColor = nil;
    NSDictionary *bgDict = (NSDictionary *)[[GlobalVariables getPlist] objectForKey:@"configuration"];
	if( bgDict ) {
		CGFloat bgRed = [(NSNumber *)[bgDict objectForKey:@"header_bg_red"] floatValue]/255.0f;
		CGFloat bgGreen =[(NSNumber *)[bgDict objectForKey:@"header_bg_green"] floatValue]/255.0f;
		CGFloat bgBlue = [(NSNumber *)[bgDict objectForKey:@"header_bg_blue"] floatValue]/255.0f;
		bgColor = [UIColor colorWithRed:bgRed green:bgGreen blue:bgBlue alpha:1.0f];
	}
    return  bgColor;
}

+(NSString*)pathForBackgroundResource
{
   return [[[GlobalVariables getPlist] objectForKey:@"configuration"]objectForKey:@"BackgroundFile"];
}
@end
