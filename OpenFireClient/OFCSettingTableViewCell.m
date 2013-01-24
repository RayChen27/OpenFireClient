//
//  OFCSettingTableViewCell.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSettingTableViewCell.h"
#import "OFCBoolSetting.h"
#import "OFCStringSetting.h"
@implementation OFCSettingTableViewCell
@synthesize ofcSetting;


- (void)setOfcSetting:(OFCSetting *)setting
{
    self.textLabel.text = setting.title;
    self.detailTextLabel.text = setting.description;
    if(setting.imageName)
    {
        self.imageView.image = [UIImage imageNamed:setting.imageName];
    }
    else
    {
        self.imageView.image = nil;
    }
    UIView *accessoryView = nil;
    if ([setting isKindOfClass:[OFCBoolSetting class]]) {
        OFCBoolSetting *boolSetting = (OFCBoolSetting *)setting;
        UISwitch *boolSwitch = nil;
        BOOL animated;
        if (ofcSetting == setting) {
            boolSwitch = (UISwitch*)self.accessoryView;
            animated = YES;
        } else {
            boolSwitch = [[UISwitch alloc] init];
            [boolSwitch addTarget:boolSetting action:boolSetting.action forControlEvents:UIControlEventValueChanged];
            animated = NO;
        }
        [boolSwitch setOn:[boolSetting enabled] animated:animated];
        accessoryView = boolSwitch;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if([setting isKindOfClass:[OFCStringSetting class]]){
        OFCStringSetting *stringSetting = (OFCStringSetting *)setting;
        UITextField *valueTextField = nil;
        if(ofcSetting == setting){
            valueTextField = (UITextField *)self.accessoryView;
        }else {
            valueTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
            valueTextField.backgroundColor = [UIColor clearColor];
            valueTextField.text = stringSetting.defaultValue;
            valueTextField.returnKeyType = UIReturnKeyDone;
            valueTextField.delegate = stringSetting;
        }
        valueTextField.text = [stringSetting value];
        accessoryView = valueTextField;
    }
    self.accessoryView = accessoryView;
    ofcSetting = setting;
    self.backgroundColor = [UIColor whiteColor];
}


@end
