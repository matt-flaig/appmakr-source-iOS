//
//  GlobalVariables.h
//  appbuildr
//
//  Created by Admin on 3/17/09.
//  Copyright 2009 PointAbout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertiesList.h"
#import "ModuleIndexPath.h"

typedef enum
{
    AppMakrTabbarTemplate = 1,
    AppMakrScrollTemplate
    
} AppMakrTemplateStyle;

typedef enum
{
    AppMakrColorBackground = 1,
    AppMakrImageBackground, 
    AppMakrLiveBackground
    
} AppMakrBackgroundStyle;

@protocol GlobalVariablesDelegate

-(void)globalVarsUpdateCompleted;

@end

@interface GlobalVariables : NSObject  {
	NSDictionary				* plist;
	NSMutableData				* _buffer;// temporary buffer to use while downloading the pList
	id<GlobalVariablesDelegate> _delegate;
}

@property (nonatomic, retain) NSDictionary * plist;

+ (NSDictionary *)getPlist;
+ (GlobalVariables *)vars;

- (void)startUpdateWithDelegate:(id<GlobalVariablesDelegate>)delegate;
@end


@interface GlobalVariables(helper)
+ (BOOL)hasGeoRssTabIn:(NSArray *)modules;
+(NSNumber *)buildID;
+(NSNumber *)appID;
+(NSString *)appName;
+(NSString *)appmakrHost;
+(NSString *)socializeHost;
+(NSDictionary*) configsForModulePath: (ModuleIndexPath*) mPath;
+(AppMakrTemplateStyle) templateType;
+(AppMakrBackgroundStyle) backgroundStyle;
+(NSString*) helpUrl;
+(NSString*) aboutPageUrl;
+(BOOL) enableMainMenu;
+(BOOL) isPremiumApp;
@end

@interface GlobalVariables(updateNotification)
+(void) addObserver: (id) observer selector: (SEL) selector;
+(void) removeObserver: (id)observer;
@end

@interface GlobalVariables(messageTab)
+(NSString*)serverName: (NSDictionary*) configs;
+(NSNumber*)portNumber: (NSDictionary*) configs;
+(NSString*)username: (NSDictionary*) configs;
+(NSString*)password: (NSDictionary*) configs;
+(NSString*)adress: (NSDictionary*) configs;
@end

@interface GlobalVariables(SocializeConfiguration)
+(BOOL)socializeEnable;
+(BOOL)enableSocialPush;
@end

@interface GlobalVariables(BackgroundStyle)
+(UIColor*)backgroundColor;
+(NSString*)pathForBackgroundResource;
@end