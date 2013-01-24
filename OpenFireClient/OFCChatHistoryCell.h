//
//  OFCChatHistoryCell.h
//  OpenFireClient
//
//  Created by CTI AD on 1/11/12.
//  Copyright (c) 2012 com.cti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFCChatHistoryCell : UITableViewCell
{
    
}

@property (nonatomic, strong) UILabel *senderAndTimeLabel;
@property (nonatomic, strong) UITextView *messageContentView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *receiptImageView;
@end
