//
//  Feed+Extensions.h
//  appbuildr
//
//  Created by William Johnson on 10/22/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Feed.h"


@interface Feed(Extensions)
-(NSArray *)entriesInOriginalOrder;
-(NSArray *)linksInOriginalOrder;
-(void)addLinksFromArray:(NSArray *)value;
@end
