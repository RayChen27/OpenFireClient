//
//  AppDelegate.h
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "OFCXMPPManager.h"
#import "OFCConstant.h"
#import "OFCBuddyListViewController.h"
#import "OFCChatViewController.h"
#import "OFCChatRoomListViewController.h"
#import "OFCSettingsViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#define  sharedDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@class OFCLoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OFCLoginViewController *viewController;

@property (strong, nonatomic) OFCXMPPManager *xmppManager;

@property (strong, nonatomic) UITabBarController *rootTabBarController;

@property (nonatomic, retain) NSTimer *backgroundTimer;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@property (nonatomic) BOOL didShowDisconnectionWarning;

@end
