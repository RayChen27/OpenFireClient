//
//  OFCBuddy.m
//  OpenFireClient
//
//  Created by CTI AD on 30/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCBuddy.h"

@implementation OFCBuddy
@synthesize status;
@synthesize displayName;
@synthesize accountName;
@synthesize groupName;
@synthesize chatMessages;
@synthesize avatarImg;
@synthesize lastMessage;
@synthesize receptionDic;
- (id)initWithDisplayName:(NSString*)buddyName accountName:(NSString*) buddyAccountName status:(OFCBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    if(self = [super init])
    {
        self.displayName=buddyName;
        self.accountName=buddyAccountName;
        self.status=buddyStatus;
        self.groupName=buddyGroupName;
        self.chatMessages = [[NSMutableArray alloc]initWithCapacity:10];
        self.receptionDic = [[NSMutableDictionary alloc]initWithCapacity:10];
    }
    return self;
}

+ (OFCBuddy*)buddyWithDisplayName:(NSString*)buddyName accountName:(NSString*) accountName status:(OFCBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName
{
    
    OFCBuddy *newBuddy = [[OFCBuddy alloc] initWithDisplayName:buddyName accountName:accountName status:buddyStatus groupName:buddyGroupName];
    return newBuddy;
}

- (void)receiveMessage:(OFCChatMessage *)newMessage
{
    [self.chatMessages addObject:newMessage];
    lastMessage = nil;
    lastMessage = [[newMessage.xmppMessage elementForName:@"body"] stringValue];
    
}
- (void)sendMessage:(NSString *)newMessage
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:newMessage];
    
    XMPPMessage *message = [XMPPMessage elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:accountName];
    [message addAttributeWithName:@"from" stringValue:[[OFCXMPPManager sharedManager].myJID full]];
    NSString * messageID = [NSString stringWithFormat:@"%d",arc4random()%10000];
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
    [receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild:receiptRequest];    
    [message addChild:body];
    OFCChatMessage *ofcMessage = [[OFCChatMessage alloc]initWithXMPPMessage:message sendTime:[NSDate date]];
    [self.chatMessages addObject:ofcMessage];
//    [[OFCXMPPManager sharedManager] sendMessage:ofcMessage];
}

@end
