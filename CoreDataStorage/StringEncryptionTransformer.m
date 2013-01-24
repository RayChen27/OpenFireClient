//
//  StringEncryptionTransformer.m
//  OpenFireClient
//
//  Created by CTI AD on 21/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import "StringEncryptionTransformer.h"

@implementation StringEncryptionTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(NSString *)string
{
    if (nil == [self key]) {
        return string;
    }
    if (nil == string) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"original utf - 8 data %@",data);
    return [super transformedValue:data];
}

- (id)reverseTransformedValue:(NSData *)data
{
    if(nil == data){
        return nil;
    }
    data = [super reverseTransformedValue:data];
//    NSLog(@"reverse utf - 8 data %@",data);
    NSString *body = [[NSString alloc] initWithBytes:[data bytes]
                                              length:[data length]
                                            encoding:NSUTF8StringEncoding];
    return body;
}
@end
