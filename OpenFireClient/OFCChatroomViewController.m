//
//  OFCChatroomViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 8/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatroomViewController.h"
#import "Strings.h"
#import "OFCXMPPManager.h"
#import "OFCSelectBuddysViewController.h"
@implementation OFCChatroomViewController
@synthesize chatroom;
@synthesize chatHistoryTableView;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(receiveGroupChat:)
                                                    name:kOFCReceiveGroupChat object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(keyboardWillShow:)
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(keyboardWillHide:)
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    chatHistoryTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kChatTableHeight) style:UITableViewStylePlain];
    [chatHistoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [chatHistoryTableView setDataSource:self];
    actionView = [[UIView alloc]initWithFrame:CGRectMake(0, 386, self.view.frame.size.width, 30)];
    [actionView setBackgroundColor:[UIColor lightGrayColor]];
    
    inputView = [[UITextField alloc]initWithFrame:CGRectMake(0, 4, 280, 20)];
    inputView.layer.cornerRadius = 10.0f;
    inputView.returnKeyType= UIReturnKeySend;
    inputView.delegate = self;
    [inputView setBackgroundColor:[UIColor whiteColor]];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame=CGRectMake(281, 0, 39, 20);
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [actionView addSubview:inputView];
    [actionView addSubview:sendBtn];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(popBuddyListView)];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:chatHistoryTableView];
    [self.view addSubview:actionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[OFCXMPPManager sharedManager] leaveChatroom];
    [self.inputView resignFirstResponder];
}

- (void)refreshView
{
    [self.chatHistoryTableView reloadData];
    if (self.chatHistoryTableView.contentSize.height > self.chatHistoryTableView.frame.size.height)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[self.chatroom messages] count]-1 inSection:0];
        [self.chatHistoryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

#pragma mark -
#pragma mark keyboard handler
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if([inputView isFirstResponder]){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        NSNumber *timeInterval = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect actionViewNewFrame = actionView.frame;
        actionViewNewFrame.origin.y -= kbSize.height;
        [UIView beginAnimations:@"keyboardShow" context:nil];
        [UIView setAnimationDuration:[timeInterval doubleValue] ];
        actionView.frame = actionViewNewFrame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if([inputView isFirstResponder]){
        NSDictionary* info = [aNotification userInfo];
        CGRect actionViewNewFrame = CGRectMake(0, kChatTableHeight, self.view.frame.size.width, 30);
        [UIView beginAnimations:@"keyboardHide" context:nil];
        NSNumber *timeInterval = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView setAnimationDuration:[timeInterval doubleValue] ];
        actionView.frame = actionViewNewFrame;
        [UIView commitAnimations];
    }
}

- (void)popBuddyListView
{
    OFCSelectBuddysViewController *selectBuddyViewController = [[OFCSelectBuddysViewController alloc]init];
    [self presentModalViewController:selectBuddyViewController animated:YES];
}

#pragma mark -
#pragma mark receive message
- (void)receiveGroupChat: (NSNotification *)notification
{
    OFCChatMessage *message = [[OFCChatMessage alloc]initWithXMPPMessage:[notification.userInfo objectForKey:@"message"] sendTime:[NSDate date]];
    [chatroom.messages addObject:message];
    [self refreshView];
}

#pragma mark -
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *messageStr = inputView.text;
    [chatroom sendMessage:messageStr];
    [inputView resignFirstResponder];
    inputView.text = nil;
    [self.chatHistoryTableView reloadData];
    return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OFCChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatHistory"];
    if(!cell){
        cell = [[OFCChatHistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatHistory"];
    }
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
    
    OFCChatMessage *message = [[chatroom messages] objectAtIndex:indexPath.row];
    
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:KOFCDateFormatter];
    
    
	UIImage *bgImage = nil;
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [[[[message xmppMessage] elementForName:@"body"] stringValue] sizeWithFont:[UIFont boldSystemFontOfSize:13]
                                                                           constrainedToSize:textSize
                                                                               lineBreakMode:UILineBreakModeWordWrap];
    
	CGFloat padding = 10.0;
	size.width += 16;
	
    
	cell.messageContentView.text = [[[message xmppMessage] elementForName:@"body"] stringValue];
    
	if (!message.iSend) { // left aligned
        
		bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:15  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(15, 32, size.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2,
											  size.width+padding/2,
											  size.height+padding)];
        
	} else {
        
		bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(320 - size.width - padding,
													 padding*2,
													 size.width,
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2,
											  size.width+padding/2,
											  size.height+padding)];
		
	}
	
	cell.bgImageView.image = bgImage;
    
	cell.senderAndTimeLabel.text = [NSString stringWithFormat:@" %@", [[message sendTime] xmppDateString]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[chatroom messages]count];
}
@end
