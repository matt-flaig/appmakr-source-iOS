//
//  NingDomainServiceDelegate.h
//  appbuildr
//
//  Created by William M. Johnson on 9/13/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NingDomainServiceDelegate <NSObject>

-(void)serviceCallBack:(NSDictionary *)responseDictionary;

@end
