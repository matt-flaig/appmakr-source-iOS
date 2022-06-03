//
//  NSPredicate+Creation.m
//  TheDisneyStoreKiosk
//
//  Created by Rolf Hendriks on 5/24/10.
//  Copyright 2010 PointAbout. All rights reserved.
//

#import "NSPredicate+Creation.h"


@implementation NSPredicate(Creation)

+ (NSPredicate*) predicateWithValue:(id)value forAttribute:(NSString*)attribute{
	return [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:attribute] 
			rightExpression:[NSExpression expressionForConstantValue:value] modifier:NSDirectPredicateModifier 
														 type:NSEqualToPredicateOperatorType options:0];
}

@end
