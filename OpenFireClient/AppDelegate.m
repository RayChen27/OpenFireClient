//
//  AppDelegate.m
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "AppDelegate.h"

#import "OFCLoginViewController.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

@interface  AppDelegate ()
{
    UIView *messageNotificationView;
}
@property (strong, nonatomic) UIView *messageNotificationView;
@end
// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation AppDelegate
@synthesize rootTabBarController;
@synthesize backgroundTask;
@synthesize messageNotificationView;
@synthesize didShowDisconnectionWarning;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    self.xmppManager = [OFCXMPPManager sharedManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[OFCLoginViewController alloc] init];
    } else {
        self.viewController = [[OFCLoginViewController alloc] init];
    }

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
#if !TARGET_IPHONE_SIMULATOR
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#endif
    if (launchOptions) {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationKey) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"推送通知"
                                                           message:@"这是通过推送窗口启动的程序，你可以在这里处理推送内容"
                                                          delegate:nil
                                                 cancelButtonTitle:@"知道了"
                                                 otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Application entered background state.");
    NSAssert(self.backgroundTask == UIBackgroundTaskInvalid, nil);
    self.didShowDisconnectionWarning = NO;
    
    self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Background task expired");
            if (self.backgroundTimer)
            {
                [self.backgroundTimer invalidate];
                self.backgroundTimer = nil;
            }
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
    });
}

- (void) timerUpdate:(NSTimer*)timer {
    UIApplication *application = [UIApplication sharedApplication];
    
    NSLog(@"Timer update, background time left: %f", application.backgroundTimeRemaining);
    
    if ([application backgroundTimeRemaining] < 60 && !self.didShowDisconnectionWarning )
    {
        self.didShowDisconnectionWarning = YES;
    }
    if ([application backgroundTimeRemaining] < 10)
    {
        // Clean up here
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.backgroundTimer)
    {
        [self.backgroundTimer invalidate];
        self.backgroundTimer = nil;
    }
    if (self.backgroundTask != UIBackgroundTaskInvalid)
    {
        [application endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.xmppManager disconnect];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    NSLog(@"Local Notification Did Receive");
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [[[[NSString stringWithFormat:@"%@",deviceToken] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:@"token"];
    [defaults synchronize];
    /*
    NSURL *url = [NSURL URLWithString:@"http://192.168.65.247:8080/RestfulDemo/rest/uploadToken"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    int ver_int = [ver intValue];
    NSNumber *version = [NSNumber numberWithInt:ver_int];
    NSDictionary *postDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",version,@"version", nil];
    [request appendPostData:[postDic JSONData]];    
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setCompletionBlock:^{
        NSLog(@"Success");
    }];
    [request setFailedBlock:^{
        NSLog(@"failed");
        NSLog(@"fail reason : %@",request.responseStatusMessage);
    }];
    [request startAsynchronous];
     */
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *message = [error localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"token" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


@end
