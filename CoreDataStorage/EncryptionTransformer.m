//
//  EncryptionTransformer.m
//  OpenFireClient
//
//  Created by CTI AD on 21/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import "EncryptionTransformer.h"

@implementation EncryptionTransformer

- (NSString *)key
{
    return @"secure key";
}

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(NSData *)data
{
    if (nil == [self key]) {
        return data;
    }
    if (nil == data) {
        return nil;
    }
    return [data AES256EncryptWithKey:[self key]];
}

- (id)reverseTransformedValue:(NSData *)data
{
    if (nil == [self key]) {
        return data;
    }
    if (nil == data) {
        return nil;
    }
    
    return [data AES256DecryptWithKey:[self key]];
}
@end
