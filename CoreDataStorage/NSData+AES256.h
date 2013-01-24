//
//  NSData+AES256.h
//  OpenFireClient
//
//  Created by CTI AD on 21/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
