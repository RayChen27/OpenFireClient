//
//  OFCXMPPManager.m
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCXMPPManager.h"
#import "OFCStrings.h"
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


static OFCXMPPManager *sharedManager = nil;

@implementation OFCXMPPManager
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppRoomDataStorage;
@synthesize myJID;


#pragma mark -
#pragma mark singleton
- (id)init
{
    self=[super init];
    if(self){
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [self setupStream];
        buddyListDic = [[NSMutableDictionary alloc]initWithCapacity:10];
        chatroomListDic = [[NSMutableDictionary alloc]initWithCapacity:1];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(sendXMPPMessage:)
                                                    name:kOFCSendMessages object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(sendGroupChat:)
                                                    name:kOFCSendGroupChat object:nil];
    }
    return self;
}

+ (OFCXMPPManager *)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark -
#pragma mark Manage Private
- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    xmppStream = [[XMPPStream alloc]init];
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
//    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithDatabaseFilename:@"XMPPRoster.sqlite"];
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    xmppRoster.autoFetchRoster = NO;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppRoomDataStorage = [[XMPPRoomCoreDataStorage alloc] initWithInMemoryStore];
    xmppMUC = [[XMPPMUC alloc]initWithDispatchQueue:dispatch_get_main_queue()];

    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    xmppMessageArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] initWithDatabaseFilename:@"XMPPMessageArchiving.sqlite"];
//    dispatch_queue_t messageArchivingQueue = dispatch_queue_create("com.hktv.message.archiving", NULL);
    
    xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingStorage dispatchQueue:dispatch_get_main_queue()];
    xmppMessageArchiving.clientSideMessageArchivingOnly = YES;
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    xmppPing = [[XMPPPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    xmppPing.respondsToQueries = YES;
    
	// Activate xmpp modules
    [xmppMUC               activate:xmppStream];
    [xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    [xmppPing              activate:xmppStream];
    [xmppMessageArchiving  activate:xmppStream];
    
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppCapabilities addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    allowSelfSignedCertificates = YES;
    allowSSLHostNameMismatch = YES;
    
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

- (void)goOnline
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
    if(![kOFCXMPPServerHost isEqualToString:@"chat.facebook.com"]){
        [self sendXMPPChatRoomQuery];
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kOFCServerLoginSuccess object:self];
//    [self requestSearchFields];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presence];
}

- (void)goIntoChatroom:(XMPPRoom *)theXmppRoom
{
    xmppRoom = theXmppRoom;
    [xmppRoom activate:xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = [[defaults objectForKey:kOFCUseNickName] boolValue];
    NSString *nickName = [defaults objectForKey:kOFCUseNickNameString];

    if(result&&nickName.length>0){
        [xmppRoom joinRoomUsingNickname:nickName history:nil];
    }else{
        [xmppRoom joinRoomUsingNickname:self.myJID.user history:nil];
    }
}
- (void)leaveChatroom
{
    [xmppRoom leaveRoom];
    [xmppRoom deactivate];
    [xmppRoom removeDelegate:self];
    xmppRoom = nil;
}
- (void)failedToConnect
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kOFCServerLoginFail object:self];
    [xmppStream disconnect];
}

- (void)sendMessageTo:(XMPPJID *)targetBareID withMessage:(NSString *)newMessage;
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:newMessage];
    
    XMPPMessage *message = [XMPPMessage elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[targetBareID full]];
    [message addAttributeWithName:@"from" stringValue:[myJID full]];
    int timeStamp = (int)[[NSDate date] timeIntervalSince1970];
    NSString * messageID = [NSString stringWithFormat:@"%@%d%@",[myJID user],timeStamp,[targetBareID user]];
    [message addAttributeWithName:@"id" stringValue:messageID];
    
    NSXMLElement * receiptRequest = [NSXMLElement elementWithName:@"request"];
    [receiptRequest addAttributeWithName:@"xmlns" stringValue:@"urn:xmpp:receipts"];
    [message addChild:receiptRequest];
    [message addChild:body];
    XMPPElementReceipt *receipt = nil;
    [xmppStream sendElement:message andGetReceipt:&receipt];
    if ([receipt wait:-1]) {

    };
}

- (void)requestSearchFields
{
 	NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
	[query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addAttributeWithName:@"id" stringValue:@"search"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",kOFCXMPPServerHost ]];
    [iq addAttributeWithName:@"from" stringValue:[myJID full]];
    [iq addChild:query];
	[xmppStream sendElement:iq];
}

- (void)sendXMPPChatRoomQuery
{
 	NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
	[query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
	
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"get"];
	[iq addAttributeWithName:@"id" stringValue:kOFCIQChatroomID];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"conference.%@",kOFCXMPPServerHost ]];
    [iq addAttributeWithName:@"from" stringValue:[myJID full]];
    [iq addChild:query];
	[xmppStream sendElement:iq];
}

- (void)receiveChatroomQueryResult:(XMPPIQ *)iq
{
    NSXMLElement *queryResult = [iq childElement];
    NSArray *roomLists = [queryResult elementsForName:@"item"];
    XMPPJID *roomJID = nil;
    for(int i = 0 ; i< [roomLists count] ; i++){
        NSXMLElement *e = [roomLists objectAtIndex:i];
        roomJID = [XMPPJID jidWithString:[e attributeStringValueForName:@"jid"]];
        if ([chatroomListDic objectForKey:[roomJID full] ]) {
            continue;
        }
        
        OFCChatroom *chatroom = [[OFCChatroom alloc]initWithRoomStorage:xmppRoomDataStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
        [chatroom setRoomName:[e attributeStringValueForName:@"name"]];
        [chatroomListDic setObject:chatroom
                            forKey:[roomJID full]];
    }
}

- (void)inviteFriendsToJoinChatroom:(NSArray *)buddyLists
{
    XMPPJID *roomJID = [XMPPJID jidWithString:@"test@conference.14.198.242.11"];
    XMPPRoom *newRoom = [[XMPPRoom alloc]initWithRoomStorage:self.xmppRoomDataStorage
                                                         jid:roomJID
                                               dispatchQueue:dispatch_get_main_queue()];

    xmppRoom = nil;
    xmppRoom = newRoom;
    selectedBuddy = nil;
    selectedBuddy = [NSArray arrayWithArray:buddyLists];
    [newRoom activate:self.xmppStream];
    [newRoom addDelegate:self
           delegateQueue:dispatch_get_main_queue()];
//    [newRoom inviteUser:userJID withMessage:@"come in"];


    [newRoom joinRoomUsingNickname:[myJID user] history:nil];
}

- (void)inviteBuddyToChatRoom
{
    for (NSString *accountName in selectedBuddy) {
        XMPPJID *userJID = [XMPPJID jidWithString:accountName];
        [xmppRoom inviteUser:userJID withMessage:@"come in"];
    }
}

- (void)sendSearchRequest:(NSString *)searchField
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
    
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *formType = [NSXMLElement elementWithName:@"field"];
    [formType addAttributeWithName:@"type" stringValue:@"hidden"];
    [formType addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [formType addChild:[NSXMLElement elementWithName:@"value" stringValue:@"jabber:iq:search" ]];

    NSXMLElement *userName = [NSXMLElement elementWithName:@"field"];
    [userName addAttributeWithName:@"var" stringValue:@"Username"];
    [userName addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1" ]];
    
    NSXMLElement *name = [NSXMLElement elementWithName:@"field"];
    [name addAttributeWithName:@"var" stringValue:@"Name"];
    [name addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    
    NSXMLElement *email = [NSXMLElement elementWithName:@"field"];
    [email addAttributeWithName:@"var" stringValue:@"Email"];
    [email addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    
    NSXMLElement *search = [NSXMLElement elementWithName:@"field"];
    [search addAttributeWithName:@"var" stringValue:@"search"];
    [search addChild:[NSXMLElement elementWithName:@"value" stringValue:searchField]];
    
    [x addChild:formType];
    [x addChild:userName];
    [x addChild:name];
    [x addChild:email];
    [x addChild:search];
    [query addChild:x];
    
    
	NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
	[iq addAttributeWithName:@"type" stringValue:@"set"];
	[iq addAttributeWithName:@"id" stringValue:[xmppStream generateUUID]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"search.%@",kOFCXMPPServerHost ]];
    [iq addAttributeWithName:@"from" stringValue:[myJID full]];
    [iq addChild:query];
	[xmppStream sendElement:iq];
}

- (void)declineInvitation:(NSString *)roomJIDString invitorJID:(NSString *)invitorJIDString
{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement *declineElement = [NSXMLElement elementWithName:@"decline"];
    [declineElement addAttributeWithName:@"to" stringValue:invitorJIDString];
    [x addChild:declineElement];
    XMPPMessage *message = [[XMPPMessage alloc]init];
    [message addAttributeWithName:@"from" stringValue:[myJID full]];
    [message addAttributeWithName:@"to" stringValue:roomJIDString];
    [message addChild:x];
    [self.xmppStream sendElement:message];
}

- (OFCChatroom *)acceptInvitation:(NSString *)roomJIDString
{
    XMPPJID *roomJID = [XMPPJID jidWithString:roomJIDString];
    OFCChatroom *chatroom = [[OFCChatroom alloc]initWithRoomStorage:xmppRoomDataStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [self goIntoChatroom:chatroom];
    return chatroom;
}

- (void)pushLocalNotification:(XMPPMessage *)message
{
    UIApplication *application = [UIApplication sharedApplication];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.applicationIconBadgeNumber = [application applicationIconBadgeNumber]+1;
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];

        NSString *alertMessage = [NSString stringWithFormat:@"%@ : %@",
                                  [[message from]user] ,
                                  [[message elementForName:@"body"] stringValue] ];
        localNotif.alertBody = alertMessage;
        localNotif.alertAction =NSLocalizedString(@"Reply", nil);
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [application presentLocalNotificationNow:localNotif];
    }else{
        NSLog(@"Not Support");
    }
}

#pragma mark -
#pragma mark XMPPStream Connect/Disconnect
- (BOOL)connectWithJID:(NSString *)JID password:(NSString *)myPassword
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    if(JID == nil || myPassword == nil)
        return NO;
    NSString *resource = [NSString stringWithFormat:@"%@",kOFCXMPPResource];
    myJID = [XMPPJID jidWithString:JID resource:resource];
    [xmppStream setMyJID:myJID];
    [xmppStream setHostName:kOFCXMPPServerHost];
    [xmppStream setHostPort:5222];
    password = myPassword;
    NSError *error;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [self teardownStream];
}
#pragma mark -
#pragma mark XMPPStream Delegate
- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}


- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	NSError *secureError = nil;
    NSError *authenticationError = nil;
    BOOL isSecureAble = (![sender isSecure])&& [sender supportsStartTLS];
	if (isSecureAble) {
        [sender secureConnection:&secureError];
    }
    
	if (![[self xmppStream] authenticateWithPassword:password error:&authenticationError])
	{
		DDLogError(@"Error authenticating: %@", authenticationError);
        isXmppConnected = NO;
        return;
	}
    isXmppConnected = YES;
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"begin");
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [xmppRoster fetchRoster];
    NSLog(@"fetch complete");
    
    [self resetRosterStatus];
    NSLog(@"fetch controller complete");
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self failedToConnect];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq type]);
    if ([[iq elementID] isEqualToString:kOFCIQChatroomID]) {
        [self receiveChatroomQueryResult:iq];
    }else if([iq isSearchResult]){
        NSDictionary *userInfo = [iq searchResults];
        [[NSNotificationCenter defaultCenter] postNotificationName:kOFCSearchResultNotification object:self userInfo:userInfo];
    }
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
        [self pushLocalNotification:message];
    }
    if([message hasReceiptRequest]){
        XMPPMessage *responseMessage = [message generateReceiptResponse];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:@"r"];
        [responseMessage addChild:body];
        [xmppStream sendElement:responseMessage];
    }
    if([message hasReceiptResponse]){
        return;
    }
	if ([message isChatMessageWithBody])
	{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[message from], FROM_JID, [[message elementForName:@"body"] stringValue], MESSAGE_BODY, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kOFCMessageNotification object:self userInfo:userInfo];
	}else if([message isGroupChatMessageWithBody]){
        if([[[message elementForName:@"body"] stringValue] isEqualToString:XMPP_CHATROOM_LOCKED]){
            [xmppRoom configureRoomUsingOptions:nil];
            return ;
        }else if([[[message elementForName:@"body"] stringValue] isEqualToString:XMPP_CHATROOM_UNLOCKED]){
            [self inviteBuddyToChatRoom];
        }
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
                                                             forKey:@"message"];
        [[NSNotificationCenter defaultCenter]postNotificationName:kOFCReceiveGroupChat object:self userInfo:userInfo];
    }else if([message isMessageWithBody]){
        
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    if([xmppMUC isMUCRoomPresence:presence]){
        NSLog(@"Get Room presence");
    }
	DDLogVerbose(@"%@: %@ - %@\nType: %@\nShow: %@\nStatus: %@", THIS_FILE, THIS_METHOD, [presence from], [presence type], [presence show],[presence status]);
    if ([presence isErrorPresence]) {
        if ([[presence elementForName:XMPP_ERROR] elementForName:XMPP_ERROR_CONFILCT]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kOFCNickNameConflictNotification object:self];
            [self leaveChatroom];
        }
    }
    NSString *type = [presence type];
    if([type isEqualToString:@"subscribe"]){
        NSLog(@"receive subscribe request");

    }

    
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kOFCServerDisconnect object:self];
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        [self failedToConnect];
	}
    else {
        //Lost connection
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_roster == nil)
	{
		managedObjectContext_roster = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppRosterStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_roster;
}

- (NSManagedObjectContext *)managedObjectContext_messages
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_messages == nil)
	{
		managedObjectContext_messages = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppMessageArchivingStorage persistentStoreCoordinator];
		[managedObjectContext_messages setPersistentStoreCoordinator:psc];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(messagesContextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_messages;
}

- (NSManagedObjectContext *)managedObjectContext_chatroom
{
    NSAssert([NSThread isMainThread],
        @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
    return nil;
}


- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	NSAssert([NSThread isMainThread],
	         @"NSManagedObjectContext is not thread safe. It must always be used on the same thread/queue");
	
	if (managedObjectContext_capabilities == nil)
	{
		managedObjectContext_capabilities = [[NSManagedObjectContext alloc] init];
		
		NSPersistentStoreCoordinator *psc = [xmppCapabilitiesStorage persistentStoreCoordinator];
		[managedObjectContext_roster setPersistentStoreCoordinator:psc];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(contextDidSave:)
		                                             name:NSManagedObjectContextDidSaveNotification
		                                           object:nil];
	}
	
	return managedObjectContext_capabilities;
}

- (void)contextDidSave:(NSNotification *)notification
{
	NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
	
	if (sender != managedObjectContext_roster &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_roster persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_roster", THIS_FILE, THIS_METHOD);
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_roster mergeChangesFromContextDidSaveNotification:notification];
            
            
		});
    }
	
    
	if (sender != managedObjectContext_capabilities &&
	    [sender persistentStoreCoordinator] == [managedObjectContext_capabilities persistentStoreCoordinator])
	{
		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_capabilities", THIS_FILE, THIS_METHOD);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_capabilities mergeChangesFromContextDidSaveNotification:notification];
		});
	}
}
- (void)messagesContextDidSave:(NSNotification *)notification
{
    NSManagedObjectContext *sender = (NSManagedObjectContext *)[notification object];
    if(sender != managedObjectContext_messages &&
       [sender persistentStoreCoordinator] == [managedObjectContext_messages persistentStoreCoordinator])
    {
 		DDLogVerbose(@"%@: %@ - Merging changes into managedObjectContext_message", THIS_FILE, THIS_METHOD);
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[managedObjectContext_messages mergeChangesFromContextDidSaveNotification:notification];
            
		});
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSuserFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSFetchedResultsController *)rosterFetchedResultsController
{
	if (rosterFetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"streamBareJidStr == %@ AND (subscription == 'both')", [[xmppStream myJID] bare]];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
		rosterFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:nil
		                                                                          cacheName:nil];
		
		NSError *error = nil;
		if (![rosterFetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
        
	}
	
	return rosterFetchedResultsController;
}

- (NSFetchedResultsController *)messagesFetchedResultsController:(NSString *)bareJidStr addDelegate:(id)delegate
{
	if (messagesFetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [self managedObjectContext_messages];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",[myJID bare], bareJidStr];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:20];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setReturnsObjectsAsFaults:NO];
		messagesFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                           managedObjectContext:moc
                                                                             sectionNameKeyPath:nil
                                                                                          cacheName:nil];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@",[myJID bare], bareJidStr];
        [messagesFetchedResultsController.fetchRequest setPredicate:predicate];
    }
    [messagesFetchedResultsController setDelegate:delegate];
    
    NSError *error = nil;
    if (![messagesFetchedResultsController performFetch:&error])
    {
        NSLog(@"Error performing fetch: %@", error);
    }
    
	
	return messagesFetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kOFCBuddyListUpdate
     object:self];
}
#pragma mark -
#pragma mark update BuddyList
- (void) resetRosterStatus
{
    NSFetchedResultsController *frc = [self rosterFetchedResultsController];
    NSArray *sections = [[self rosterFetchedResultsController] sections];
    int sectionsCount = [[[self rosterFetchedResultsController] sections] count];
    for(int sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        for(int j = 0; j < sectionInfo.numberOfObjects; j++)
        {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:sectionIndex];
            XMPPUserCoreDataStorageObject *user = [frc objectAtIndexPath:indexPath];
            [user setSection:2];
        }
    }
}

- (NSArray *)fetchRosters
{
    NSManagedObjectContext *moc = [self managedObjectContext_roster];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"streamBareJidStr == %@", [[xmppStream myJID] bare]];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:10];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSError *error = nil;
    return [moc executeFetchRequest:fetchRequest error:&error];

}

- (NSArray *)updateChatroomList
{
    return [chatroomListDic allValues];
}

#pragma mark -
#pragma mark XMPPRoom Delegate
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOFCDidJoinChatroom object:self];
}
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
}


#pragma mark -
#pragma mark XMPPMUC 
- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:@"message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOFCReceiveInvitationNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitationDecline:(XMPPMessage *)message
{
    NSString *alertMessage = [NSString stringWithFormat:@"%@ decline the invitation",[message declineFromString]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invitation Decline" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
     DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
     
//     XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
//     xmppStream:xmppStream
//     managedObjectContext:[self managedObjectContext_roster]];
    
     NSString *displayName = [[presence from] user];
     NSString *jidStrBare = [presence fromStr];
     NSString *body = nil;
     
     if (![displayName isEqualToString:jidStrBare])
     {
         body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
     }
     else
     {
         body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
     }
     UIAlertView *subscriptionAlertView = [[UIAlertView alloc]initWithTitle:@"Subscription"
                                                                    message:body
                                                                   delegate:self
                                                          cancelButtonTitle:@"Deny"
                                                          otherButtonTitles:@"Accept", nil];
    if (subscriptions == nil) {
        subscriptions = [NSMutableDictionary dictionary];
    }
    subscriptionAlertView.delegate = self;
    NSInteger hash = [[presence from] hash];
    subscriptionAlertView.tag = hash;
    [subscriptions setObject:[presence from] forKey:[NSNumber numberWithInt:hash]];
    [subscriptionAlertView show];
 }

#pragma mark -
#pragma mark AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Click Button on %d", buttonIndex);
    XMPPJID *fromJID = [subscriptions objectForKey:[NSNumber numberWithInt:alertView.tag]];
    switch (buttonIndex) {
        case 0:
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:fromJID];
            break;
        case 1:
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:fromJID andAddToRoster:YES];
            [self.xmppRoster subscribePresenceToUser:fromJID];
            break;
        default:
            break;
    }
}

@end
