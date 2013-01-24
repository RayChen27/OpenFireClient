//
//  XMPPIQ+XEP_0055.h
//  OpenFireClient
//
//  Created by CTI AD on 24/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "XMPPIQ.h"
@interface XMPPIQ (XEP_0055)

- (BOOL)isSearchResult;
- (NSDictionary *)searchResults;
@end
