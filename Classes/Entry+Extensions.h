//
//  Entry+Extensions.h
//  appbuildr
//
//  Created by William Johnson on 10/21/10.
//  Copyright 2010 pointabout. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Entry.h"
#import "Link.h"

@class Statistics;

@interface Entry(Extensions)
//@property (nonatomic, retain) Statistics * statistics;

-(NSString *)toJavascript;
-(NSString*) printJSobjectWithTitle:(NSString*) titleId author:(NSString*) authorId date: (NSString*) dateId content: (NSString*)contetId;
-(Link *)getMediaLink;
-(NSString *) getDisplayContent;

- (NSArray *)linksInOriginalOrder;

-(NSString *) moduleType;
- (void)addLinksFromArray:(NSArray *)value;


@end
