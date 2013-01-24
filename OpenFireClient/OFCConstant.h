//
//  OFCConstant.h
//  OpenFireClient
//
//  Created by CTI AD on 30/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

//Notification
#define kOFCServerLoginFail @"loginFailedNotification"
#define kOFCServerLoginSuccess @"loginSuccessNotification"
#define kOFCNickNameConflictNotification @"nickNameConflictNotification"
#define kOFCMessageNotification @"messageNotification"
#define kOFCDidQueuedNotification @"messageDidQueuedNotification"
#define kOFCReceiveInvitationNotification @"receiveInvitationNotification"
#define kOFCSearchResultNotification @"searchResultNotification"

#define kOFCXMPPResource @"openfireiOS"
#define kOFCStatusUpdate @"statusUpdate"
#define kOFCServerDisconnect @"serverDisconnect"
#define kOFCBuddyListUpdate @"buddyListUpdate"
#define kOFCReceiveGroupChat @"receiveGroupChat"
#define kOFCSendMessages @"sendMessages"

#define kOFCSendGroupChat @"sendGroupChat"
#define KOFCDateFormatter @"yyyy-MM-dd HH:mm:ss"
#define kOFCIQChatroomID @"XEP0045"

//Config Setting
#define kOFCUseNickName @"useNickName"
#define kOFCUseNickNameString @"nickNameString"
#define kOFCSendReceptionRequest @"sendReceptionRequest"

#define kOFCDidJoinChatroom @"didJoinChatroom"
#define kOFCXMPPServerDomain @"14.198.242.11"
#define kOFCXMPPServerHost @"14.198.242.11"


#define XMPP_ERROR @"error"
#define XMPP_ERROR_CONFILCT @"conflict"
#define XMPP_ERROR_CONFILCT_NS @"urn:ietf:params:xml:ns:xmpp-stanzas"
#define XMPP_CHATROOM_LOCKED @"This room is locked from entry until configuration is confirmed."
#define XMPP_CHATROOM_UNLOCKED @"This room is now unlocked."

#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
