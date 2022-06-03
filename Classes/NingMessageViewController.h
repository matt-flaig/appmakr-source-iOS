//
//  NingMessageViewController.h
//  appbuildr
//
//  Created by Isaac Mosquera on 9/13/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"
#import "NingDomainServiceDelegate.h"

@class NingDomainService;
@interface NingMessageViewController : MessageViewController <UITextFieldDelegate, NingDomainServiceDelegate>
{

	UITextField *titleTextField;
	
	NingDomainService *ningService;
	
	NSString * NingApiType;
}

@property(nonatomic, copy) NSString * NingApiType;

@end
