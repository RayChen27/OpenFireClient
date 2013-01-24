//
//  OFCBoolSetting.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCBoolSetting.h"

@implementation OFCBoolSetting
@synthesize action;

- (id) initWithTitle:(NSString *)newTitle description:(NSString *)newDescription settingsKey:(NSString *)newSettingsKey
{
    if (self = [super initWithTitle:newTitle description:newDescription settingsKey:newSettingsKey])
    {
        self.action = @selector(toggle);
        self.defaultValue = [NSNumber numberWithBool:NO];
    }
    return self;
}

- (void) toggle
{
    [self setEnabled:![self enabled]];
}

- (void) setEnabled:(BOOL)enabled
{
    [self setValue:[NSNumber numberWithBool:enabled]];
    [self.delegate refreshView];
}

- (BOOL) enabled
{
    if (![self value])
    {
        self.value = self.defaultValue;
    }
    return [[self value] boolValue];
}
@end
