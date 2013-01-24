//
//  OFCChatMessages.h
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface OFCChatMessage : NSObject
{
    NSDate *sendTime;
    BOOL iSend;
    BOOL didQueued;
}
@property (nonatomic,copy) XMPPMessage *xmppMessage;

@property (nonatomic,strong) NSDate *sendTime;

@property (nonatomic) BOOL iSend;

@property (nonatomic) BOOL didQueued;

-(id)initWithXMPPMessage:(XMPPMessage *)theMessage sendTime:(NSDate *)theSendTime;
@end
