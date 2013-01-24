//
//  OFCSettingsGroup.h
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OFCSettingsGroup : NSObject
@property (nonatomic, retain, readonly) NSArray *settings;
@property (nonatomic, retain, readonly) NSString *title;

- (id) initWithTitle:(NSString*)newTitle settings:(NSArray*)newSettings;
@end
