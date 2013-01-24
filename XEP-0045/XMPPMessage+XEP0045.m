#import "XMPPMessage+XEP0045.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPRoom.h"

@implementation XMPPMessage(XEP0045)

- (BOOL)isGroupChatMessage
{
	return [[[self attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (BOOL)isGroupChatMessageWithBody
{
	if ([self isGroupChatMessage])
	{
		NSString *body = [[self elementForName:@"body"] stringValue];
		
		return ((body != nil) && ([body length] > 0));
	}
	
	return NO;
}

- (NSString *)declineFromString
{
    NSString *declineJIDString = [[[self elementForName:@"x" xmlns:XMPPMUCUserNamespace] elementForName:@"decline"] attributeStringValueForName:@"from"];
	NSRange atRange = [declineJIDString rangeOfString:@"@"];
	NSString *userString = nil;
	if (atRange.location != NSNotFound)
	{
		userString = [declineJIDString substringToIndex:atRange.location];
    }
    return userString;
}
@end
