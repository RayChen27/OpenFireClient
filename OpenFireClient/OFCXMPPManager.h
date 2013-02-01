//
//  OFCXMPPManager.h
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "DDLog.h"
#import "OFCConstant.h"
#import "OFCBuddy.h"
#import "OFCChatroom.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "OFCChatMessage.h"
@interface OFCXMPPManager : NSObject <XMPPRosterDelegate,NSFetchedResultsControllerDelegate>
{
    
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPMUC *xmppMUC;
    XMPPRoom *xmppRoom;
    XMPPPing *xmppPing;
	
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPRoomCoreDataStorage *xmppRoomDataStorage;
    
    XMPPMessageArchiving *xmppMessageArchiving;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
    
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;

	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    XMPPJID *myJID;
    
    NSString *password;
    BOOL isXmppConnected;
    
    BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
    
    BOOL isAnoymous;
    
    NSManagedObjectContext *managedObjectContext_roster;
    NSManagedObjectContext *managedObjectContext_messages;
	NSManagedObjectContext *managedObjectContext_capabilities;
    
    NSFetchedResultsController *rosterFetchedResultsController;
    NSFetchedResultsController *messagesFetchedResultsController;
    NSMutableDictionary *buddyListDic;
    NSMutableDictionary *chatroomListDic;
    
    NSArray *selectedBuddy;
    
}

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, readonly) XMPPRoomCoreDataStorage *xmppRoomDataStorage;
@property (nonatomic, strong) XMPPJID *myJID;
+ (OFCXMPPManager *)sharedManager;
- (BOOL)connectWithJID:(NSString *)JID password:(NSString *)myPassword;
- (BOOL)anoymousConnection;
- (void)disconnect;
- (NSArray *)updateChatroomList;
- (NSArray *)fetchRosters;
- (void)goIntoChatroom:(XMPPRoom *)xmppRoom;
- (void)leaveChatroom;
- (void)sendMessageTo:(XMPPJID *)targetBareID withMessage:(NSString *)newMessage;
- (void)inviteFriendsToJoinChatroom:(NSArray *)buddyLists;
- (void)declineInvitation:(NSString *)roomJIDString invitorJID:(NSString *)invitorJIDString;
- (OFCChatroom *)acceptInvitation:(NSString *)roomJIDString;
- (NSFetchedResultsController *)messagesFetchedResultsController:(NSString *)bareJidStr addDelegate:(id)delegate;
- (NSFetchedResultsController *)rosterFetchedResultsController;
- (void)sendSearchRequest:(NSString *)searchField;
@end
