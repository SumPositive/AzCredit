//
//  NSData_Encrypt.m
//  AzCredit-0.4
//
//  Created by Sum Positive on 11/01/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "NSData_Crypto.h"


@implementation NSData (Additions)

// AES256暗号化
- (NSData *)Encrypt:(NSString *)key 
{
	char pcKey[kCCKeySizeAES256+1];
	bzero(pcKey, sizeof(pcKey));
	
	
	[key getCString:pcKey maxLength:sizeof(pcKey) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,       
										  kCCOptionPKCS7Padding | kCCOptionECBMode,
										  pcKey, kCCBlockSizeAES128,
										  NULL,
										  [self bytes], dataLength,
										  buffer, bufferSize,
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	free(buffer);
	return nil;
}


// AES256復号化
- (NSData *)Decrypt:(NSString *)key 
{
	char keyPtr[kCCKeySizeAES256+1];
	bzero(keyPtr, sizeof(keyPtr));
	
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 
										  kCCOptionPKCS7Padding | kCCOptionECBMode,
										  keyPtr, kCCBlockSizeAES128,
										  NULL,
										  [self bytes], dataLength,
										  buffer, bufferSize,
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	free(buffer);
	return nil;
}


// base64 エンコード
static const char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
- (NSString *)stringBase64
{
	NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
	unsigned char * working = (unsigned char *)[self bytes];
	int srcLen = [self length];
	
	for (int i=0; i<srcLen; i += 3) {
		for (int nib=0; nib<4; nib++) {
			int byt = (nib == 0)?0:nib-1;
			int ix = (nib+1)*2;
			
			if (i+byt >= srcLen) break;
			
			unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
			
			if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
			
			[dest appendFormat:@"%c", base64[curr]];
		}
	}
	return dest;
}

@end