//
//  OFCSettingsViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OFCSettingsManager.h"
#import "OFCStrings.h"
@interface OFCSettingsViewController : UIViewController <UITableViewDataSource,                                                       OFCSettingDelegate,
UITableViewDelegate>
{
    UITableView *settingsTableView;
    OFCSettingsManager *settingsManager;
}
@property (nonatomic, retain) UITableView *settingsTableView;
@property (nonatomic, retain) OFCSettingsManager *settingsManager;
@end
