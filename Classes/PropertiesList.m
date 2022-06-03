//
//  PropertiesList.m
//  appbuildr
//
//  Created by PointAboutAdmin on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PropertiesList.h"


@implementation PropertiesList

//
//  PropertiesList.m
//  pointabout_iphone
//
//  Created by Isaac Mosquera on 10/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PropertiesList.h"

@implementation PropertiesList

@synthesize plist;
static PropertiesList *propertyVars = nil;

- (void) initVariables {
    NSString *error;
    NSPropertyListFormat format;
	
    NSData *plistData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"global" ofType:@"plist" inDirectory:@"/"]];
	propertyVars.plist= [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	
    if(propertyVars.plist) {
        NSLog(error);
        [error release];
    }
	
}
- (id) getObjectByKey:(NSString *)aKey {
    return [self.plist objectForKey: aKey];
}

- (id) init {
    self = [super init];
    [self initVariables];
    return self;
}

+ (PropertiesList *)sharedInstance {
    @synchronized(self) {
        if (propertyVars == nil) {
            [[self allocWithZone:NULL] init]; // assignment not done here
        }
    }
    return propertyVars;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (propertyVars == nil) {
            propertyVars = [super allocWithZone:zone];
            return propertyVars;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

@end
