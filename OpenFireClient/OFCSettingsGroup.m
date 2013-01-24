//
//  OFCSettingsGroup.m
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSettingsGroup.h"

@implementation OFCSettingsGroup
@synthesize title = _title;
@synthesize settings = _settings;
- (void) dealloc
{
    _title = nil;
    _settings = nil;
}

- (id) initWithTitle:(NSString*)newTitle settings:(NSArray*)newSettings
{
    if (self = [super init])
    {
        _title = newTitle;
        _settings = newSettings;
    }
    return self;
}
@end
