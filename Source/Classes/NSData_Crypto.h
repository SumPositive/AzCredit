//
//  NSData_Encrypt.h
//  AzCredit-0.4
//
//  Created by Sum Positive on 11/01/15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class NSString; 

@interface NSData (Additions)
- (NSData *)Encrypt:(NSString *)key;
- (NSData *)Decrypt:(NSString *)key;
- (NSString *)stringBase64;
@end

/*

 // キーの作成
 NSString *key = @"afmoifjonfalsnfoasdlfmploasmfs";
 
 // 暗号化
 NSData *plain = [textField.text dataUsingEncoding:NSUTF8StringEncoding];
 NSData *cipher = [plain Encrypt:key];
 NSLog(@"Encrypt: %@", [cipher description]);
 NSLog(@"Base64: %@", [cipher stringBase64]);
 
 // 暗号化解除
 plain = [cipher Decrypt:key];
 NSLog(@"Decrypt: %@", [[[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding] autorelease]);

*/
