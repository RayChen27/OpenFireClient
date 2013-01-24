//
//  OFCSettingsManager.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSettingsManager.h"
#import "OFCBoolSetting.h"
#import "OFCStringSetting.h"
#import "OFCSettingsGroup.h"
#import "OFCStrings.h"
#import "OFCConstant.h"
@implementation OFCSettingsManager
@synthesize settingsGroups ;
@synthesize settingsDictionary ;

- (id) init
{
    if (self = [super init])
    {
        settingsGroups = [NSMutableArray array];
        [self populateSettings];
    }
    return self;
}

- (void) populateSettings
{
    OFCBoolSetting *useNickNameSetting = [[OFCBoolSetting alloc]initWithTitle:EN_NICK_NAME_SETTING_STRING description:EN_NICK_NAME_DESC_STRING settingsKey:kOFCUseNickName];
    
    OFCStringSetting *nickNameStringSetting = [[OFCStringSetting alloc]initWithTitle:EN_NICK_NAME_SETTING_STRING description:@"" settingsKey:kOFCUseNickNameString];
    
    OFCBoolSetting *allowReceptionAndRequest = [[OFCBoolSetting alloc]initWithTitle:EN_RECEPTION_SETTING_STRING description:@"" settingsKey:kOFCSendReceptionRequest];
    
    OFCSettingsGroup *chatSettingsGroup = [[OFCSettingsGroup alloc] initWithTitle:CHAT_STRING settings:[NSArray arrayWithObjects:useNickNameSetting,nickNameStringSetting,allowReceptionAndRequest, nil]];
    
    [settingsGroups addObject:chatSettingsGroup];
}

- (NSUInteger) numberOfSettingsInSection:(NSUInteger)section
{
    OFCSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:section];
    return [settingsGroup.settings count];
}

- (OFCSetting*) settingAtIndexPath:(NSIndexPath*)indexPath
{
    OFCSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:indexPath.section];
    return [settingsGroup.settings objectAtIndex:indexPath.row];
}

- (NSString*) stringForGroupInSection:(NSUInteger)section
{
    OFCSettingsGroup *settingsGroup = [settingsGroups objectAtIndex:section];
    return settingsGroup.title;
}
@end
