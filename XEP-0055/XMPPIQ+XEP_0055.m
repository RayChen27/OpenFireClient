//
//  XMPPIQ+XEP_0055.m
//  OpenFireClient
//
//  Created by CTI AD on 24/1/13.
//  Copyright (c) 2013 com.cti. All rights reserved.
//

#import "XMPPIQ+XEP_0055.h"
#import "NSXMLElement+XMPP.h"
static NSString *const xmlns_search = @"jabber:iq:search";
static NSString *const xmlns_data =  @"jabber:x:data";

@implementation XMPPIQ (XEP_0055)

- (BOOL)isSearchResult
{
    return [self isResultIQ] && ([[self childElement] elementForName:@"x" xmlns:xmlns_data]);
}

- (NSDictionary *)searchResults
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
    NSArray *tmpItems = [[[self childElement] elementForName:@"x" xmlns:xmlns_data] elementsForName:@"item"];
    for(int itemindex = 0; itemindex < [tmpItems count] ; itemindex++) {
        NSXMLElement *item = [tmpItems objectAtIndex:itemindex];
        NSArray *fields = [item elementsForName:@"field"];
        NSMutableDictionary *values = [[NSMutableDictionary alloc]initWithCapacity:1];
        for (int fieldIndex = 0; fieldIndex < [fields count]; fieldIndex++) {
            NSXMLElement *field = [fields objectAtIndex:fieldIndex];
            [values setObject:[[field elementForName:@"value"] stringValue] forKey:[field attributeStringValueForName:@"var"]];
        }
        [items addObject:values];
    }
    NSDictionary *itemsDic = [NSDictionary dictionaryWithObject:items forKey:@"items"];
    return itemsDic;
}
@end
