//
//  SoundServices.m
//  appbuildr
//
//  Created by Admin  on 12/16/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "SoundServices.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation SoundServices
+ (void)playSoundWithName:(NSString *)fileName type:(NSString *)fileExtension
{
	
	CFStringRef cfFileName = (CFStringRef) fileName;
	CFStringRef cfFileExtension = (CFStringRef) fileExtension;
	
	CFBundleRef mainBundle;
	mainBundle = CFBundleGetMainBundle ();
	
	CFURLRef soundURLRef  = CFBundleCopyResourceURL (mainBundle, cfFileName, cfFileExtension, NULL);
	
	SystemSoundID soundID;
	
	AudioServicesCreateSystemSoundID (soundURLRef, &soundID);
	
	
	AudioServicesPlaySystemSound (soundID);
	
	CFRelease(soundURLRef);
	
}

+ (void)vibrateDevice
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
