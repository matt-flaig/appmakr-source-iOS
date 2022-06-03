//
//  ATOMParser.h
//  appbuildr
//
//  Created by Isaac Mosquera on 10/1/09.
//  Copyright 2009 pointabout. All rights reserved.
//

#import "AbstractParser.h"

@interface ATOMParser : AbstractParser 
{

	NSDictionary *namespaceDict;
}

-(id) initWithDocument:(CXMLDocument *)theDoc id:(NSObject *)calledObject;

@end
