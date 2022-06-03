//
//  GeoPointParser.h
//  appbuildr
//
//  Created by Isaac Mosquera on 6/7/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "Entry.h"
#import "CXMLDocument.h"

@class DataStore;
@interface GeoParser : NSObject 
{

	  DataStore * objectStore;
}

@property(retain) DataStore * objectStore;

-(void)parseGeoWithEntry:(Entry *)entry xmlElement:(CXMLElement *)xmlElement;
@end
