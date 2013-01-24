//
//  OFCSettingsViewController.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSettingsViewController.h"
#import "OFCSettingTableViewCell.h"

@implementation OFCSettingsViewController
@synthesize settingsTableView;
@synthesize settingsManager;
- (id)init
{
    self = [super init];
    if(self){
        self.title = EN_SETTINGS_STRING;
        self.settingsManager = [[OFCSettingsManager alloc]init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settingsTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.settingsTableView setBackgroundColor:[UIColor lightGrayColor]];
    [self.settingsTableView setDataSource:self];
    [self.settingsTableView setDelegate:self];
    [self.view addSubview: self.settingsTableView];
    
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingsManager.settingsGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.settingsManager numberOfSettingsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    OFCSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
		cell = [[OFCSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
	}
    OFCSetting *setting = [settingsManager settingAtIndexPath:indexPath];
    setting.delegate = self;
    cell.ofcSetting = setting;
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [settingsManager stringForGroupInSection:section];
}

#pragma mark -
#pragma mark UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark OFCSettingDelegate
- (void)refreshView
{
    [self.settingsTableView reloadData];
}
- (void) ofcSetting:(OFCSetting *)setting showDetailViewControllerClass:(Class)viewControllerClass
{
    
}


@end
