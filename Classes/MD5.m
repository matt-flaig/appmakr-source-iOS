//
//  MD5.m
//  appbuildr
//
//  Created by Isaac Mosquera on 5/6/10.
//  Copyright 2010 pointabout. All rights reserved.
//

#import "MD5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation MD5

+(NSString * ) hash:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}
@end
