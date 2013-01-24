//
//  OFCSettingsManager.h
//  OpenFireClient
//
//  Created by CTI AD on 17/12/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OFCSetting.h"
@interface OFCSettingsManager : NSObject
{
    NSMutableArray *settingsGroups;
    NSDictionary *settingsDictionary;
}
@property (nonatomic, strong, readonly) NSMutableArray *settingsGroups;
@property (nonatomic, strong, readonly) NSDictionary *settingsDictionary;

- (NSUInteger) numberOfSettingsInSection:(NSUInteger)section;
- (OFCSetting *) settingAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*) stringForGroupInSection:(NSUInteger)section;
@end
