//
//  ModuleFactory.h
//  appbuildr
//
//  Created by Nitin Alabur on 12/2/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *  const moduleTypeGeoRss;
extern NSString *  const moduleTypeAlbum;
extern NSString *  const moduleTypeRss;
extern NSString *  const moduleTypeHTML;
extern NSString *  const moduleTypeNing;
extern NSString *  const moduleTypeMessage;



@interface ModuleFactory : NSObject 
{

}
+(UIViewController *)getViewControllerForModule:(NSDictionary *)module atIndex:(int)index;
+(NSString *)tabTitle:(NSDictionary *)module;
+(NSString *)feedUrl:(NSDictionary *)module;

@end
