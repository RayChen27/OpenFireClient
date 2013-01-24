//
//  EncryptionTransformer.h
//  OpenFireClient
//
//  Created by CTI AD on 21/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+AES256.h"
@interface EncryptionTransformer : NSValueTransformer

- (NSString *)key;
@end
