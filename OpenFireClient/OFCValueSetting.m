//
//  OFCValueSetting.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCValueSetting.h"

@implementation OFCValueSetting
@synthesize key;
@synthesize value;
@synthesize defaultValue;
- (void) dealloc
{
    key = nil;
}

- (id) initWithTitle:(NSString*)newTitle description:(NSString*)newDescription settingsKey:(NSString*)newSettingsKey;
{
    if (self = [super initWithTitle:newTitle description:newDescription])
    {
        key = newSettingsKey;
    }
    return self;
}

- (id) value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

- (void) setValue:(id)settingsValue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:settingsValue forKey:key];
    [defaults synchronize];
}
@end
