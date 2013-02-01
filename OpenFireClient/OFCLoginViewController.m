//
//  OFCLoginViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCLoginViewController.h"
@interface OFCLoginViewController ()

@end

@implementation OFCLoginViewController
@synthesize JID;
@synthesize password;
- (id)init
{
    self = [super init];
    if(self){
        [self.view setBackgroundColor:[UIColor grayColor]];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(serverLoginFailed:)
         name:kOFCServerLoginFail
         object:nil ];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(serverLoginSuccess:)
         name:kOFCServerLoginSuccess
         object:nil ];
        
        didLogined = NO;
    }
    return self;
}

-(void)loadView{
    [super loadView];
    
    JIDField = [[UITextField alloc]initWithFrame:CGRectMake(50, 20, 150, 30)];
    [JIDField setBackgroundColor:[UIColor whiteColor]];
    [JIDField setTextAlignment:NSTextAlignmentLeft];
    [JIDField setReturnKeyType:UIReturnKeyDone];
    [JIDField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [JIDField becomeFirstResponder];
    [JIDField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [JIDField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    pwField = [[UITextField alloc]initWithFrame:CGRectMake(50, 55, 150, 30)];
    [pwField setTextAlignment:NSTextAlignmentLeft];
    [pwField setBackgroundColor:[UIColor whiteColor]];
    [pwField setReturnKeyType:UIReturnKeyDone];
    [pwField setSecureTextEntry:YES];
    [pwField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginBtn setFrame:CGRectMake(50, 100, 100, 30)];
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginXMPPServer) forControlEvents:UIControlEventTouchUpInside];
    
    resetBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [resetBtn setFrame:CGRectMake(200, 100, 100, 30)];
    [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetFields) forControlEvents:UIControlEventTouchUpInside];
    
    anoymousBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [anoymousBtn setFrame:CGRectMake(50, 150, 100, 30)];
    [anoymousBtn setTitle:@"Anoymous" forState:UIControlStateNormal];
    [anoymousBtn addTarget:self action:@selector(anoymousLoginXMPPServer) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:resetBtn];
    [self.view addSubview:loginBtn];
    [self.view addSubview:anoymousBtn];
    [self.view addSubview:JIDField];
    [self.view addSubview:pwField];
}
- (void)viewDidLoad
{
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginXMPPServer
{
    if(JIDField.text == nil || pwField == nil){
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Please input JID and password" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alterView show];
        return;
    }
    NSString *completeJID = [JIDField.text stringByAppendingFormat:@"@%@",kOFCXMPPServerDomain];
    if(![[OFCXMPPManager sharedManager]connectWithJID:completeJID password:pwField.text]){
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Please Check your network" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alterView show];
    }
}

-(void)resetFields
{
    JIDField.text = nil;
    pwField.text  = nil;
    [JIDField becomeFirstResponder];
}

-(void)anoymousLoginXMPPServer
{
//    NSString *completeJID = [JIDField.text stringByAppendingFormat:@"@%@",kOFCXMPPServerDomain];
    if(![[OFCXMPPManager sharedManager]anoymousConnection]){
        UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Connection Failed" message:@"Please Check your network" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
        [alterView show];
    }
}
-(void)serverLoginSuccess:(NSNotification*)notification
{
    [self initialRootTabController];
    if(!didLogined){
        [self presentModalViewController:[sharedDelegate rootTabBarController] animated:YES];
        didLogined = YES;
    }
#if !TARGET_IPHONE_SIMULATOR
    NSURL *url = [NSURL URLWithString:@"http://14.198.242.6/RestfulDemo/uploadToken"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    NSString *ver = [[UIDevice currentDevice] systemVersion];
//    int ver_int = [ver intValue];
//    NSNumber *version = [NSNumber numberWithInt:ver_int];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"token"];
    NSString *JIDString = [[[OFCXMPPManager sharedManager] myJID] bare];
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",
                             JIDString,@"userJID",
                             @"ios",@"os",
                             ver,@"version",
                             nil];
    [request appendPostData:[postDic JSONData]];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setCompletionBlock:^{
        NSLog(@"Success register");
    }];
    [request setFailedBlock:^{
        NSLog(@"failed");
        NSLog(@"fail reason : %@",request.responseStatusMessage);
    }];
    [request startAsynchronous];
#endif
}
-(void)serverLoginFailed:(NSNotification*)notification
{
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"Failed to connect server" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil, nil];
    [alterView show];
}

- (void)initialRootTabController
{
    NSLog(@"Start initial");
    OFCChatRoomListViewController *chatRoomListViewController = [[OFCChatRoomListViewController alloc]init];
    UINavigationController *chatroomListNavController = [[UINavigationController alloc]initWithRootViewController:chatRoomListViewController];
    
    OFCSettingsViewController *settingViewController = [[OFCSettingsViewController alloc]init];
    UINavigationController *settingsNavController = [[UINavigationController alloc]initWithRootViewController:settingViewController];
    
    OFCBuddyListViewController *buddyListViewController = [[OFCBuddyListViewController alloc]init];
    UINavigationController *buddlyListNavController = [[UINavigationController alloc]initWithRootViewController:buddyListViewController];
    OFCChatViewController *chatViewController = [[OFCChatViewController alloc]init];
    buddyListViewController.chatViewController = chatViewController;
    
    buddlyListNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Friends"
                                                                       image:nil
                                                                         tag:0];
    
    chatroomListNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chatroom"
                                                                         image:nil
                                                                           tag:1];
    
    settingsNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings"
                                                                     image:nil
                                                                       tag:2];
    
    
    sharedDelegate.rootTabBarController = [[UITabBarController alloc]init];
    sharedDelegate.rootTabBarController.viewControllers = [NSArray arrayWithObjects:buddlyListNavController,chatroomListNavController, settingsNavController, nil];
}
@end
