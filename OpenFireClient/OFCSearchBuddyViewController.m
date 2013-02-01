//
//  OFCSearchBuddyViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 14/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import "OFCSearchBuddyViewController.h"

@interface OFCSearchBuddyViewController ()
{
    UITableView *resultsTableView;
    UITextField *searchTextField;
    UIButton *searchButton;
    NSArray *results;
}
@property (nonatomic, strong) UITableView *resultsTableView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) NSArray *results;
@end

@implementation OFCSearchBuddyViewController
@synthesize resultsTableView;
@synthesize searchButton;
@synthesize searchTextField;
@synthesize results;
- (id)init
{
    self = [super init];
    if (self) {
        self.searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 2, 270, 36)];
        self.searchTextField.backgroundColor =  [UIColor whiteColor];
        self.searchTextField.layer.cornerRadius = 8.0f;
        self.searchTextField.layer.shadowRadius = 4.0f;
        self.searchTextField.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
        self.searchTextField.layer.borderColor = [[UIColor blackColor] CGColor];
        self.searchTextField.layer.borderWidth = 1.0f;
        
        UIFont *font = [UIFont fontWithName:@"System" size:16.0f];
        self.searchTextField.font = font;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.searchButton.frame = CGRectMake(275 , 2, 40, 36);
        [self.searchButton addTarget:self action:@selector(sendSearchRequestToServer) forControlEvents:UIControlEventTouchUpInside];
        
        self.resultsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, 320, self.view.bounds.size.height) style:UITableViewStylePlain];
        self.resultsTableView.dataSource = self;
        self.resultsTableView.delegate = self;
        [self.view addSubview:self.searchTextField];
        [self.view addSubview:self.searchButton];
        [self.view addSubview:self.resultsTableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResults:) name:kOFCSearchResultNotification object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)sendSearchRequestToServer
{
    NSString *searchCriteria = self.searchTextField.text;
    if (searchCriteria && searchCriteria.length > 0) {
        [[OFCXMPPManager sharedManager] sendSearchRequest:searchCriteria];
    }
    [self.searchTextField resignFirstResponder];
}

- (void)refreshResults:(NSNotification *)notification
{
    self.results = [[notification userInfo] objectForKey:@"items"];
    [self.resultsTableView reloadData];
}

#pragma mark -
#pragma mark UITableView Datasource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultcell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"resultcell"];
    }
    NSDictionary *item = [results objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item objectForKey:@"Name"];
    cell.detailTextLabel.text = [item objectForKey:@"Email"];
    return cell;
}


#pragma mark -
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *item = [results objectAtIndex:indexPath.row];
    [[OFCXMPPManager sharedManager].xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[item objectForKey:@"jid"]]];
}
@end
