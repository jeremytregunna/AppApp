//
//  ANStatusCell.m
//  AppApp
//
//  Created by brandon on 8/27/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANStatusCell.h"
#import "NSDictionary+SDExtensions.h"
#import "NSDate+SDExtensions.h"
#import "NSDate+ANExtensions.h"

static UIImage *cellTop = nil;
static UIImage *cellMiddle = nil;
static UIImage *cellBottom = nil;

@implementation ANStatusCell
@synthesize avatarView;
@synthesize usernameTextLabel;
@synthesize statusTextLabel;
@synthesize created_atTextLabel;
@synthesize showUserButton;
@synthesize replyButton;
@synthesize repostButton;
@synthesize convoButton;
@synthesize showActionBar;

+ (CGFloat)baseHeight:(BOOL)showActionBar
{
    if (showActionBar)
        return 136;
    return 75;
}

+ (CGFloat)baseTextHeight
{
    return 38;
}

+ (void)initialize
{
    // setup our constantly redrawn images.
    cellTop = [UIImage imageNamed:@"statusCellTop.png"];
    cellMiddle = [UIImage imageNamed:@"statusCellMiddle.png"];
    cellBottom = [UIImage imageNamed:@"statusCellBottom.png"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [cellTop drawInRect:CGRectMake(0, 0, 320, 62)];
    [cellMiddle drawInRect:CGRectMake(0, 62, 320, rect.size.height - 2)];
    [cellBottom drawInRect:CGRectMake(0, rect.size.height - 2, 320, 2)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
    avatarView.image = [UIImage imageNamed:@"avatarPlaceholder.png"];
    statusTextLabel.text = nil;
    created_atTextLabel.text = nil;
    usernameTextLabel.text = nil;
    self.showActionBar = NO;
}

- (void)setShowActionBar:(BOOL)value
{
    //if (showActionBar == value)
    //    return;
    
    showActionBar = value;
    
    if (showActionBar)
    {
        replyButton.hidden = NO;
        repostButton.hidden = NO;
        convoButton.hidden = NO;
        self.postView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        replyButton.hidden = YES;
        repostButton.hidden = YES;
        convoButton.hidden = YES;
        self.postView.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:247.0/255.0 blue:251.0/255.0 alpha:1.0];
    }
}

- (void)setPostData:(NSDictionary *)postData
{
    _postData = postData;
    
    statusTextLabel.postData = self.postData;

    CGSize size = [statusTextLabel sizeThatFits:CGSizeMake(230, 10000)];
    CGRect statusLabelNewFrame = statusTextLabel.frame;
    statusLabelNewFrame.size.height = size.height;
    statusTextLabel.frame = statusLabelNewFrame;
    
    NSString *username = [self.postData stringForKeyPath:@"user.username"];
    usernameTextLabel.text = username;
    
    NSDate *createdAt = [NSDate dateFromISO8601String:[self.postData stringForKey:@"created_at"]];
    created_atTextLabel.text = [createdAt stringInterval];
    
    NSString *avatarURL = [self.postData stringForKeyPath:@"user.avatar_image.url"];
    avatarView.imageURL = avatarURL;
}

@end
