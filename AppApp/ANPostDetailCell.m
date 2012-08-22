//
//  ANPostDetailHeaderView.m
//  AppApp
//
//  Created by brandon on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ANPostDetailCell.h"

@interface ANPostDetailCell ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@end

@implementation ANPostDetailCell

@synthesize postLabel;
@synthesize userImageView;
@synthesize nameLabel;
@synthesize usernameLabel;
@synthesize replyButton;
@synthesize repostButton;
@synthesize userButton;
@synthesize topView;
@synthesize arrowImageView;
@synthesize bottomView;

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self addObserver:self forKeyPath:@"topView.frame" options:NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:self forKeyPath:@"bottomView.frame" options:NSKeyValueObservingOptionOld context:NULL];
}

- (void)drawTopShadow
{
    CGFloat baseHeight = CGRectGetHeight(self.topView.frame);
    CGFloat baseWidth = CGRectGetWidth(self.topView.frame);
    CGFloat arrowMinX = CGRectGetMinX(self.arrowImageView.frame);
    UIBezierPath *path = [UIBezierPath bezierPath];

    [path moveToPoint:CGPointMake(0, baseHeight)];
    [path addLineToPoint:CGPointMake(arrowMinX, baseHeight)];
    [path addLineToPoint:CGPointMake(arrowMinX + self.arrowImageView.frame.size.width / 2, baseHeight + self.arrowImageView.frame.size.height)];
    [path addLineToPoint:CGPointMake(arrowMinX + self.arrowImageView.frame.size.width, baseHeight)];
    [path addLineToPoint:CGPointMake(baseWidth, baseHeight)];
    [path addLineToPoint:CGPointMake(baseWidth, baseHeight - 4)];
    [path addLineToPoint:CGPointMake(0, baseHeight - 4)];

    self.topView.layer.shadowOffset = CGSizeMake(0, 2);
    self.topView.layer.shadowRadius = 2;
    self.topView.layer.shadowOpacity = 0.7f;
    self.topView.layer.shadowPath = path.CGPath;
    self.topView.layer.masksToBounds = NO;
}

- (void)drawBottomShadow
{
    self.bottomView.layer.shadowOffset = CGSizeMake(0, -2);
    self.bottomView.layer.shadowRadius = 2;
    self.bottomView.layer.shadowOpacity = 0.7;
    self.bottomView.layer.masksToBounds = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"topView.frame"])
        [self drawTopShadow];
    else if([keyPath isEqualToString:@"bottomView.frame"])
        [self drawBottomShadow];
}

@end
