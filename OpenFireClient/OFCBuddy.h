//
//  OFCBuddy.h
//  OpenFireClient
//
//  Created by CTI AD on 30/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OFCChatMessage.h"
#import "OFCConstant.h"
#import "OFCXMPPManager.h"
typedef unsigned int OFCBuddyStatus;
typedef unsigned int OFCChatState;

#define MESSAGE_PROCESSED_NOTIFICATION @"MessageProcessedNotification"
#define kOFCEncryptionStateNotification @"kOFCEncryptionStateNotification"


enum OFCBuddyStatus {
    kOFCBuddyStatusOffline = 0,
    kOFCBuddyStatusAway = 1,
    kOFCBuddyStatusAvailable = 2
};

enum OFCChatState {
    kOFCChatStateUnknown =0,
    kOFCChatStateActive = 1,
    kOFCChatStateComposing = 2,
    kOFCChatStatePaused = 3,
    kOFCChatStateInactive = 4,
    kOFCChatStateGone =5
};
@interface OFCBuddy : NSObject{
    OFCBuddyStatus status;
    NSString *displayName;
    NSString * accountName;
    NSString *groupName;
    NSMutableArray *chatMessages;
    UIImage *avatarImg;
    NSString *lastMessage;
    NSMutableDictionary *receptionDic;
}
@property (nonatomic, copy, readonly) NSString *lastMessage;
@property (nonatomic) OFCBuddyStatus status;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *accountName;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSMutableArray *chatMessages;
@property (nonatomic, strong) UIImage *avatarImg;
@property (nonatomic, strong) NSMutableDictionary *receptionDic;

+ (OFCBuddy*)buddyWithDisplayName:(NSString*)buddyName accountName:(NSString*) accountName status:(OFCBuddyStatus)buddyStatus groupName:(NSString*)buddyGroupName;
- (void)receiveMessage:(OFCChatMessage *)newMessage;
- (void)sendMessage:(NSString *)newMessage;

@end
