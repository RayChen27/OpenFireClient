//
//  ViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OFCBuddy.h"
#import "OFCChatViewController.h"
#import "OFCSettingsViewController.h"
@interface OFCBuddyListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
{
    UITableView *buddyListTableView;
    OFCChatViewController *chatViewController;
    NSMutableDictionary *buddyDictionary;
    UIAlertView *messageAlertView;
    NSFetchedResultsController *rosterFetchedResultsController;
}

@property (nonatomic,strong) OFCChatViewController *chatViewController;
@end
