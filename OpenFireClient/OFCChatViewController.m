//
//  OFCChatViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatViewController.h"

@interface OFCChatViewController ()

@end

@implementation OFCChatViewController
@synthesize chatToBuddy;
@synthesize chatToBuddyJID;
@synthesize chatHistoryTableView;
- (id)init
{
    self = [super init];
    if(self){
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(refreshView)
                                                    name:kOFCDidQueuedNotification
                                                  object:nil];
        
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    chatHistoryTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kChatTableHeight) style:UITableViewStylePlain];
    [chatHistoryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [chatHistoryTableView setDataSource:self];
    [chatHistoryTableView setDelegate:self];
    

    
    actionView = [[UIView alloc]initWithFrame:CGRectMake(0, kChatTableHeight, self.view.frame.size.width, 30)];
    [actionView setBackgroundColor:[UIColor lightGrayColor]];
    
    inputView = [[UITextView alloc]initWithFrame:CGRectMake(0, 4, 280, 20)];
    inputView.layer.cornerRadius = 3.0f;
    inputView.layer.borderColor = [UIColor blackColor].CGColor;
    inputView.layer.borderWidth = 1;
    inputView.layer.shadowOffset = CGSizeMake(-2, 2);
    inputView.layer.shadowRadius = 5.0;
    inputView.layer.shadowOpacity = 0.8;
    inputView.delegate = self;
    [inputView setBackgroundColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:inputView action:@selector(resignFirstResponder)];
    singleTap.numberOfTapsRequired = 1;
    [chatHistoryTableView addGestureRecognizer:singleTap];
    
    sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame=CGRectMake(281, 0, 39, 20);
    [sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    
    [actionView addSubview:inputView];
    [actionView addSubview:sendBtn];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:chatHistoryTableView];
    [self.view addSubview:actionView];

    messageArray = [[NSMutableArray alloc]initWithCapacity:20];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshChatView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    messagesFetchResultsController.delegate = nil;
    messagesFetchResultsController = nil;
    [self.inputView resignFirstResponder];
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

- (void)refreshChatView
{
    [messageArray removeAllObjects];
    self.title = [chatToBuddyJID user];
    messagesFetchResultsController = [[OFCXMPPManager sharedManager] messagesFetchedResultsController:[chatToBuddyJID bare]  addDelegate:self];
    [self fetchHistoryMessages];
    [chatHistoryTableView reloadData];
    [self moveContentViewToEnd];
}

- (void)moveContentViewToEnd
{
    if (self.chatHistoryTableView.contentSize.height > self.chatHistoryTableView.frame.size.height)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        [self.chatHistoryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void )fetchHistoryMessages
{
    NSArray *sections = [messagesFetchResultsController sections];
    int sectionsCount = [[messagesFetchResultsController sections] count];
    for(int sectionIndex = 0; sectionIndex < sectionsCount; sectionIndex++)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        for (int row = 0; row < sectionInfo.numberOfObjects ; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
            [messageArray addObject:[messagesFetchResultsController objectAtIndexPath:indexPath]];
        }
    }
}

- (void)sendMessage
{
    if([inputView.text length] > 0){
        NSString *messageStr = inputView.text;
        [[OFCXMPPManager sharedManager] sendMessageTo:chatToBuddyJID withMessage:messageStr];
    }
    inputView.text = nil;
    [inputView resignFirstResponder];
}

#pragma mark -
#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [inputView resignFirstResponder];
    if([textField.text length] > 0){
        NSString *messageStr = inputView.text;
        [[OFCXMPPManager sharedManager] sendMessageTo:chatToBuddyJID withMessage:messageStr];
    }
    inputView.text = nil;
    return YES;
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
        CGRect chatHistoryViewNewFrame = chatHistoryTableView.frame;
        actionViewNewFrame.origin.y -= kbSize.height;
        chatHistoryViewNewFrame.size.height -= kbSize.height;
        [UIView beginAnimations:@"keyboardShow" context:nil];
        [UIView setAnimationDuration:[timeInterval doubleValue] ];
        actionView.frame = actionViewNewFrame;
        chatHistoryTableView.frame = chatHistoryViewNewFrame;
        [self moveContentViewToEnd];
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if([inputView isFirstResponder]){
        NSDictionary* info = [aNotification userInfo];
        CGRect actionViewNewFrame = CGRectMake(0, kChatTableHeight, self.view.frame.size.width, 30);
        CGRect chatHistoryViewNewFrame = CGRectMake(0, 0, self.view.frame.size.width, kChatTableHeight);
        [UIView beginAnimations:@"keyboardHide" context:nil];
        NSNumber *timeInterval = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView setAnimationDuration:[timeInterval doubleValue] ];
        actionView.frame = actionViewNewFrame;
        chatHistoryTableView.frame = chatHistoryViewNewFrame;
        [self moveContentViewToEnd];
        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [chatHistoryTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
         [messageArray addObject:[messagesFetchResultsController objectAtIndexPath:newIndexPath]];
            [chatHistoryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [chatHistoryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [chatHistoryTableView endUpdates];
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
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [messageArray objectAtIndex:indexPath.row];
    
	UIImage *bgImage = nil;
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [[message body] sizeWithFont:[UIFont boldSystemFontOfSize:13]
                                     constrainedToSize:textSize
                                         lineBreakMode:UILineBreakModeWordWrap];
    
	CGFloat padding = 10.0;
	size.width += 16;
	
    
	cell.messageContentView.text = [message body];
    BOOL isOutgoing = [message isOutgoing];
	if (isOutgoing) { // left aligned
        
		bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:15  topCapHeight:15];
		
		[cell.messageContentView setFrame:CGRectMake(15, 32, size.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2,
											  size.width+padding/2,
											  size.height+padding)];
        
        UIImage *receiptImage = nil;
        if(message.isMessageDelivered){
            receiptImage = [UIImage imageNamed:@"mark_d.png"];

        }else if(message.isServerDelivered){
            receiptImage = [UIImage imageNamed:@"mark_s.png"];
        }
        [cell.contentView addSubview:cell.receiptImageView];
        cell.receiptImageView.frame = CGRectMake(0, 0, 15.0f, 12.0f);
        cell.receiptImageView.layer.contents = (id)receiptImage.CGImage;
        [cell.receiptImageView setCenter:CGPointMake(cell.bgImageView.frame.origin.x+cell.bgImageView.frame.size.width,
                                                     cell.bgImageView.frame.origin.y+cell.bgImageView.frame.size.height)];
	} else {
        
		bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
		[cell.receiptImageView removeFromSuperview];
		[cell.messageContentView setFrame:CGRectMake(320 - size.width - padding,
													 32,
													 size.width,
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2,
											  size.width+padding/2,
											  size.height+padding)];
		
	}
	
	cell.bgImageView.layer.contents = (id)bgImage.CGImage;
	cell.senderAndTimeLabel.text = [[message timestamp] xmppDateTimeString];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = [messageArray objectAtIndex:indexPath.row];
	CGSize  textSize = { 260.0, 10000.0 };
	CGSize size = [[message body] sizeWithFont:[UIFont boldSystemFontOfSize:13]
                             constrainedToSize:textSize
                                 lineBreakMode:UILineBreakModeWordWrap];
    CGFloat padding = 10.0;
    size.height += padding*2;
    CGFloat height = size.height < 55 ? 55 : size.height;
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}
@end
