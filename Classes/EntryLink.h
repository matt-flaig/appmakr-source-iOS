//
//  EntryLink.h
//  appbuildr
//
//  Created by William Johnson on 11/10/10.
//  Copyright 2010 PointAbout, Inc. All rights reserved.
//

#import "Link.h"

@class Entry;

@interface EntryLink :  Link 
{
}

@property (nonatomic, retain) Entry * entry;

@end



