//
//  ViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 29/10/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCBuddyListViewController.h"
#import "OFCSearchBuddyViewController.h"
#import "OFCStrings.h"
@implementation OFCBuddyListViewController
@synthesize chatViewController;
-(id)init
{
    self = [super init];
    if(self){
        self.title = EN_BUDDY_LIST_STRING;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pushSearchBuddyView)];
        buddyListTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-92) style:UITableViewStylePlain];
        [buddyListTableView setDataSource:self];
        [buddyListTableView setDelegate:self];
        [self.view addSubview:buddyListTableView];
        messageAlertView = [[UIAlertView alloc]initWithTitle:nil
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:IGNORE_STRING
                                           otherButtonTitles:REPLY_STRING, nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(receiveNewMessages:)
         name:kOFCMessageNotification
         object:nil];
        
        buddyDictionary = [[NSMutableDictionary alloc]initWithCapacity:1];
        
        rosterFetchedResultsController = [[OFCXMPPManager sharedManager] rosterFetchedResultsController];
        rosterFetchedResultsController.delegate = self;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [buddyListTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)viewDidDisappear:(BOOL)animated
{

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveNewMessages:(NSNotification*)notification;
{
    XMPPJID *fromJID = [[notification userInfo] objectForKey:FROM_JID];
    NSString *messageBody = [[notification userInfo] objectForKey:MESSAGE_BODY];
    BOOL chatViewIsVisible = chatViewController.isViewLoaded && chatViewController.view.window && [[fromJID bare] isEqualToString:chatViewController.chatToBuddyJID.bare];
    if ( !chatViewIsVisible && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [messageAlertView setTitle:[fromJID user]];
        [messageAlertView setMessage:messageBody];
        NSInteger tag = [fromJID hash];
        [buddyDictionary setObject:fromJID forKey:[NSNumber numberWithInt:tag ]];
        messageAlertView.tag = tag;
        if (![messageAlertView isVisible]) {
            [messageAlertView show];
        }
    } 
    notification = nil;
}

- (void)enterConversationView:(XMPPJID *)xmppJID
{
    [self.chatViewController setChatToBuddyJID:xmppJID];
    if([[sharedDelegate rootTabBarController] selectedViewController]!=0){
        [((UINavigationController *)[[sharedDelegate rootTabBarController] selectedViewController]).visibleViewController.navigationController popToRootViewControllerAnimated:NO];
        [[sharedDelegate rootTabBarController] setSelectedIndex:0];
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.chatViewController refreshChatView];
    [self.navigationController pushViewController:self.chatViewController animated:YES];
}

- (void)pushSearchBuddyView
{
    OFCSearchBuddyViewController *searchBuddyView = [[OFCSearchBuddyViewController alloc] init];
    [self.navigationController pushViewController:searchBuddyView animated:YES];
}
#pragma mark -
#pragma mark UITableViewDataSource Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[rosterFetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buddy"];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"buddy"];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    XMPPUserCoreDataStorageObject *roster = [rosterFetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText: [roster valueForKey:@"displayName" ]];
    [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
    switch ([roster.sectionNum intValue]) {
        case 0:
            [cell.detailTextLabel setText:@"Available"];
            cell.imageView.image = [UIImage imageNamed:@"available.png"];
            break;
        case 1:
            [cell.detailTextLabel setText:@"Away"];
            cell.imageView.image = [UIImage imageNamed:@"away.png"];
            break;
        default:
            [cell.detailTextLabel setText:@"Offline"];
            cell.imageView.image = [UIImage imageNamed:@"offline.png"];
            break;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *roster = [rosterFetchedResultsController objectAtIndexPath:indexPath];
    [self.chatViewController setChatToBuddyJID: [roster jid]];
    [self.navigationController pushViewController:self.chatViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark UIAlterView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        XMPPJID *xmppJID= [buddyDictionary objectForKey:[NSNumber numberWithInt:alertView.tag]];
        if(xmppJID){
            [self enterConversationView:xmppJID];
        }
    }
    [buddyDictionary removeAllObjects];
}

#pragma mark -
#pragma mark NSFetchedResultsController Delegate
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [buddyListTableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    switch (type) {
//        case NSFetchedResultsChangeMove:
//            [buddyListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:NO];
//            [buddyListTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath ] withRowAnimation:NO];
//            break;
//        default:
//            break;
//    }
//}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [buddyListTableView reloadData];
}
@end
