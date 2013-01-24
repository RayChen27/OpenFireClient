//
//  OFCLoginViewController.h
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OFCConstant.h"

@interface OFCLoginViewController : UIViewController
{
    NSString *JID;
    NSString *password;
    
    UITextField *JIDField;
    UITextField *pwField;
    UIButton *loginBtn;
    UIButton *resetBtn;
    BOOL didLogined;
}
@property (nonatomic,strong) NSString *JID;
@property (nonatomic,strong) NSString *password;
@end
