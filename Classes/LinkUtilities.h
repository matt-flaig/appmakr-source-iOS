//
//  LinkUtilities.h
//  appbuildr
//
//  Created by William Johnson on 11/4/10.
//  Copyright 2010 pointabout. All rights reserved.
//

@interface LinkUtilities : NSObject 
{

}

+(NSString *) getHrefExtension:(NSString *)href;
+(BOOL) hasVideo:(NSString *)href;
@end
