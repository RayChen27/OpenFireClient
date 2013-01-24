//
//  OFCStringSetting.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCStringSetting.h"

@implementation OFCStringSetting

- (id) initWithTitle:(NSString *)newTitle description:(NSString *)newDescription settingsKey:(NSString *)newSettingsKey
{
    if (self = [super initWithTitle:newTitle description:newDescription settingsKey:newSettingsKey])
    {
        self.action = @selector(input:);
    }
    return self;
}

- (void)input:(UITextField *)textField
{
    [self setValue: textField.text];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self input:textField];
    
    [textField resignFirstResponder];
    
    return YES;
}
@end
