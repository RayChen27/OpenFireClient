//
//  OFCChatroom.m
//  OpenFireClient
//
//  Created by CTI AD on 6/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatroom.h"

@implementation OFCChatroom
@synthesize roomName;
@synthesize messages;
- (id)initWithRoomJID:(XMPPJID *)JID roomName:(NSString *)name
{
    self = [super init];
    if(self){
        self.roomName = name;
        self.messages = [[NSMutableArray alloc]initWithCapacity:10];
    }
    return self;
}

- (NSMutableArray *)messages
{
    if(!messages){
        messages = [[NSMutableArray alloc]initWithCapacity:10];
    }
    return messages;
}
@end
