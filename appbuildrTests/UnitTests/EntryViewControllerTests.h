//
//  EntryViewControllerTests.h
//  appbuildr
//
//  Created by Sergey Popenko on 11/11/11.
//  Copyright (c) 2011 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h>
#import "EntryViewController.h"

@interface EntryViewControllerTests : GHTestCase
{
    EntryViewController* controller;
    id mockEntry;
    BOOL internetStatus;
}
@end
