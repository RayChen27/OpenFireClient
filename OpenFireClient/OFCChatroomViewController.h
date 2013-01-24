//
//  OFCChatroomViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 8/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OFCChatroom.h"
#import "OFCChatHistoryCell.h"
#import "OFCConstant.h"
#import "OFCChatMessage.h"
#define kChatTableHeight 386

@interface OFCChatroomViewController : UIViewController <UITableViewDataSource, UITextFieldDelegate>
{
    UITableView *chatHistoryTableView;
    UIView *actionView;
    UITextField *inputView;
    UIButton *sendBtn;
    OFCChatroom *chatroom;
}
@property (nonatomic,strong)  UITableView *chatHistoryTableView;
@property (nonatomic,strong)  OFCChatroom *chatroom;
@end
