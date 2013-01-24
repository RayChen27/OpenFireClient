//
//  OFCChatroom.h
//  OpenFireClient
//
//  Created by CTI AD on 6/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface OFCChatroom : XMPPRoom
{
    NSMutableArray *messages;
}

@property (strong, nonatomic) NSString *roomName;
@property (strong, nonatomic) NSMutableArray *messages;

@end
