//
//  OFCChatViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OFCBuddy.h"
#import "OFCChatHistoryCell.h"
#import "OFCChatMessage.h"
#import "OFCConstant.h"
#define kChatTableHeight 386


@interface OFCChatViewController : UIViewController <UITextFieldDelegate,   UITableViewDataSource,  NSFetchedResultsControllerDelegate, UITableViewDelegate, UITextViewDelegate >
{
    UITableView                 *chatHistoryTableView;
    UIView                      *actionView;
    UITextView                  *inputView;
    UIButton                    *sendBtn;
    OFCBuddy                    *chatToBuddy;
    XMPPJID                     *chatToBuddyJID;
    NSFetchedResultsController  *messagesFetchResultsController;
    NSMutableArray              *messageArray;
}
@property (nonatomic,strong)  OFCBuddy *chatToBuddy;
@property (nonatomic,strong)  XMPPJID *chatToBuddyJID;
@property (nonatomic,strong)  UITableView *chatHistoryTableView;
- (void)refreshChatView;
@end
