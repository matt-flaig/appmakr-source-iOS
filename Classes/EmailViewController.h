//
//  EmailViewController.h
//  appbuildr
//
//  Created by William M. Johnson on 7/14/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageViewController.h"
#import "SKPSMTPMessage.h"

@interface EmailViewController : MessageViewController <SKPSMTPMessageDelegate>
{

}

@end
