//
//  OFCBoolSetting.h
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCSetting.h"
#import "OFCValueSetting.h"
@interface OFCBoolSetting : OFCValueSetting

@property (nonatomic) BOOL enabled;

- (void) toggle;

@end
