//
//  OFCValueSetting.h
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSetting.h"

@interface OFCValueSetting : OFCSetting
@property (nonatomic, retain, readonly) NSString *key;
@property (nonatomic, retain) id value;
@property (nonatomic, retain) id defaultValue;


- (id) initWithTitle:(NSString*)newTitle description:(NSString*)newDescription settingsKey:(NSString*)newSettingsKey;

@end
