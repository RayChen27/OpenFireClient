//
//  OFCSelectBuddysViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 21/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFCSelectBuddysViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>
{
    UITableView *buddyListTableView;
    NSArray *rosterList;
    UIButton *createButton;
    UINavigationBar *navigationBar;
}
@property (nonatomic, strong) UITableView *buddyListTableView;
@property (nonatomic, strong) NSArray *rosterList;
@property (nonatomic, strong) UIButton *createButton;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@end
