//
//  OFCChatRoomListViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 5/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OFCChatroom.h"
#import "OFCChatroomViewController.h"
#import "OFCSelectBuddysViewController.h"
@interface OFCChatRoomListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
{
    UITableView *chatroomListView;
    NSArray *chatroomList;
    OFCChatroomViewController *chatroomViewController;
    NSMutableDictionary *inviteDic;
}
@property (nonatomic,strong) NSArray *chatroomList;
@property (nonatomic,strong)  UITableView *chatroomListView;
@property (nonatomic,strong)  OFCChatroomViewController *chatroomViewController;
@end
