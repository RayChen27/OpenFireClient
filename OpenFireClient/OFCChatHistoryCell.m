//
//  OFCChatHistoryCell.m
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import "OFCChatHistoryCell.h"

@implementation OFCChatHistoryCell
@synthesize bgImageView;
@synthesize senderAndTimeLabel;
@synthesize messageContentView;
@synthesize receiptImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
        senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:senderAndTimeLabel];
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        receiptImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:receiptImageView];
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        messageContentView.editable = NO;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
        [self.contentView addSubview:messageContentView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
