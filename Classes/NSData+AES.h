//
//  NSData+AES.h
//  MacCryptoLibrary
//
//  Created by William M. Johnson on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSData(AES) 
//-(NSData *)AESEncryptWithKey:(NSString *)key;
- (NSData *)AESEncryptWithKey:(NSData *)key; 
@end
