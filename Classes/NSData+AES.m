//
//  NSData+AES.m
//  MacCryptoLibrary
//
//  Created by William M. Johnson on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "NSData+AES.h"


@implementation NSData(AES)

//- (NSData *)AESEncryptWithKey:(NSString *)key 
//{
//	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
//	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused) // oorspronkelijk 256
//	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
//	
//	// fetch key data
//	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
//	
//	NSUInteger dataLength = [self length];
//	
//	//See the doc: For block ciphers, the output size will always be less than or 
//	//equal to the input size plus the size of one block.
//	//That's why we need to add the size of one block here
//	size_t bufferSize = dataLength + kCCBlockSizeAES128;
//	void *buffer = malloc(bufferSize);
//	
//	size_t numBytesEncrypted = 0;
//	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
//										  keyPtr, kCCKeySizeAES128, // oorspronkelijk 256
//										  NULL /* initialization vector (optional) */,
//										  [self bytes], dataLength, /* input */
//										  buffer, bufferSize, /* output */
//										  &numBytesEncrypted);
//	
//	if (cryptStatus == kCCSuccess) {
//		//the returned NSData takes ownership of the buffer and will free it on deallocation
//		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
//	}
//	
//	free(buffer); //free the buffer;
//	return nil;
//}

- (NSData *)AESEncryptWithKey:(NSData *)key 
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	unsigned char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused) // oorspronkelijk 256
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	//[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	[key getBytes:keyPtr length:sizeof(keyPtr)];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES128, // oorspronkelijk 256
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}


@end
