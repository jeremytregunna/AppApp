//
//  ANStatusViewCell.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"
#import "TTTAttributedLabel.h"

extern CGFloat const ANStatusViewCellTopMargin;
extern CGFloat const ANStatusViewCellBottomMargin;
extern CGFloat const ANStatusViewCellLeftMargin;
extern CGFloat const ANStatusViewCellUsernameTextHeight;
extern CGFloat const ANStatusViewCellAvatarHeight;
extern CGFloat const ANStatusViewCellAvatarWidth;

@interface ANStatusViewCell : UITableViewCell <TTTAttributedLabelDelegate>
{
    CALayer* _leftBorder;
    CALayer* _bottomBorder;
    CALayer* _topBorder;
    CALayer* _avatarConnector;
}
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *created_at;

@property (nonatomic, strong) UIImage  *avatar;

@property (nonatomic, readonly) SDImageView *avatarView;
@property (nonatomic, readonly) UIButton *showUserButton;
@property (nonatomic, readonly) TTTAttributedLabel *statusTextLabel;
@property (nonatomic, readonly) UIView* postView;

@end
