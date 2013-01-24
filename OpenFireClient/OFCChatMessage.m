//
//  OFCChatMessages.m
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatMessage.h"

@implementation OFCChatMessage
@synthesize sendTime;

@synthesize iSend;

@synthesize didQueued;

@synthesize xmppMessage;
-(id)initWithContent:(NSString *)theContent sendTime:(NSDate *) theSendTime isISend:(BOOL) isIsend
{
    self = [super init];
    if(self){

        self.iSend = isIsend;
    }
    return self;
}
-(id)initWithXMPPMessage:(XMPPMessage *)theMessage sendTime:(NSDate *)theSendTime
{
    self = [super init];
    if(self){
        self.sendTime = theSendTime;
        self.xmppMessage = theMessage;
    }
    return self;
}
@end
