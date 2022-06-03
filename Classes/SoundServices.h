//
//  SoundServices.h
//  appbuildr
//
//  Created by Admin  on 12/16/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SoundServices : NSObject {

}
+ (void)playSoundWithName:(NSString *)fileName type:(NSString *)fileExtension;
+ (void)vibrateDevice;

@end
