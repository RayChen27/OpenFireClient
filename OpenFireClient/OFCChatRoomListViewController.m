//
//  OFCChatRoomListViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 5/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatRoomListViewController.h"
#import "OFCStrings.h"

@implementation OFCChatRoomListViewController
@synthesize chatroomList;
@synthesize chatroomListView;
@synthesize chatroomViewController;
- (id)init
{
    self = [super init];
    if(self){
        self.title = EN_CHATROOM_STRING;
        chatroomListView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"14-gear.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSettingsView)];        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target: self action:@selector(popBuddyListView)];
        [chatroomListView setDelegate:self];
        [chatroomListView setDataSource:self];
        [self.view addSubview:chatroomListView];
        inviteDic = [[NSMutableDictionary alloc]initWithCapacity:1];
        chatroomViewController = [[OFCChatroomViewController alloc]init];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(pushChatroomView)
                                                    name:kOFCDidJoinChatroom
                                                  object:nil ];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(showNickNameConflictAlter)
                                                    name:kOFCNickNameConflictNotification
                                                  object:nil ];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(receiveInvitation:)
                                                    name:kOFCReceiveInvitationNotification
                                                  object:nil];
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    chatroomList = [sharedDelegate.xmppManager updateChatroomList];
    [chatroomListView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:chatroomListView];
//    [self.view addSubview:chatroomListView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableViewDataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatroomList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatroomcell"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chatroomcell"];
    }
    OFCChatroom *chatroom =  [chatroomList objectAtIndex:indexPath.row];
    cell.textLabel.text = [chatroom roomName];
    cell.detailTextLabel.text = [[chatroom roomJID]full];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    chatroomViewController.chatroom  = [chatroomList objectAtIndex:indexPath.row];
    [[OFCXMPPManager sharedManager] goIntoChatroom:chatroomViewController.chatroom];
}

- (void)pushChatroomView
{
    BOOL chatViewIsVisible = chatroomViewController.isViewLoaded && chatroomViewController.view.window;
    if(chatViewIsVisible){
        return;
    }
    [self.navigationController pushViewController:chatroomViewController animated:YES];
}

- (void)showNickNameConflictAlter
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Nick Name exists" message:@"Please change nick name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)receiveInvitation:(NSNotification *)notification
{
    XMPPMessage *message = [[notification userInfo] objectForKey:@"message"];
    NSXMLElement *x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
    NSXMLElement *invite = [x elementForName:@"invite"];
    NSXMLElement *directInvite = [message elementForName:@"x" xmlns:@"jabber:x:conference"];
    XMPPJID *invitor = [XMPPJID jidWithString:[invite attributeStringValueForName:@"from"]];
    NSString *inviteMessage = [NSString stringWithFormat:@"%@ invite you to join conference",[invitor user]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invitation" message:inviteMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Decline", nil];
    alert.tag = 1001;
    NSString *roomJIDString = [directInvite attributeStringValueForName:@"jid"] ;
    NSDictionary *invitationDetails = [NSDictionary dictionaryWithObjectsAndKeys:roomJIDString,@"roomJIDString",[invitor full],@"invitorJIDString", nil];
    [inviteDic setObject:invitationDetails forKey:[NSString stringWithFormat:@"%d",alert.tag]];
    [alert show];
}

- (void)popBuddyListView
{
    OFCSelectBuddysViewController *selectBuddyViewController = [[OFCSelectBuddysViewController alloc]init];
    [self presentModalViewController:selectBuddyViewController animated:YES];
}

- (void)enterGroupChatView
{
    if([[sharedDelegate rootTabBarController] selectedViewController]!=self){
        [((UINavigationController *)[[sharedDelegate rootTabBarController] selectedViewController]).visibleViewController.navigationController popToRootViewControllerAnimated:NO];
        [[sharedDelegate rootTabBarController] setSelectedIndex:1];
    }
}
#pragma mark -
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSDictionary *invitationDetails = [inviteDic objectForKey:[NSString stringWithFormat:@"%d",alertView.tag ]];
    NSString *roomJID = [invitationDetails objectForKey:@"roomJIDString"];
    NSString *invitorJIDString = [invitationDetails objectForKey:@"invitorJIDString"];
    
    if(buttonIndex == 1){
        [[OFCXMPPManager sharedManager] declineInvitation:roomJID invitorJID:invitorJIDString] ;
    }else if(buttonIndex == 0){
        OFCChatroom *room = [[OFCXMPPManager sharedManager] acceptInvitation : roomJID ];
        chatroomViewController.chatroom = room;
        BOOL chatViewVisiable = (chatroomViewController.isViewLoaded && chatroomViewController.view.window) || (self.isViewLoaded && self.view.window );
        if(!chatViewVisiable){
            [self enterGroupChatView];
        }
    }
}

@end
