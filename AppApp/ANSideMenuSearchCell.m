//
//  ANSideMenuSearchCell.m
//  AppApp
//
//  Created by protozog on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANSideMenuSearchCell.h"

@implementation ANSideMenuSearchCell
{
    CGRect initialHashTagImageViewFrame;
    CGRect initialSearchFieldFrame;
    BOOL _hashtagVisible;
}

- (void)awakeFromNib
{
    initialHashTagImageViewFrame = self.hashTagImageView.frame;
    initialSearchFieldFrame = self.searchTextField.frame;
    
    self.searchTextField.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16.0f];
    self.hashTagImageView.alpha = 0.0f;
}

- (void)showHashTag
{
    if (_hashtagVisible) return;
    
    CGRect targHashTagRect = CGRectMake(70.0f, CGRectGetMinY(self.hashTagImageView.frame), CGRectGetWidth(self.hashTagImageView.frame), CGRectGetHeight(self.hashTagImageView.frame));
    
    CGRect targSearchFieldRect = CGRectMake(90.0f, CGRectGetMinY(self.searchTextField.frame), CGRectGetWidth(self.searchTextField.frame), CGRectGetHeight(self.searchTextField.frame));
    
    [UIView animateWithDuration:.35 animations:^{
        self.hashTagImageView.alpha = 1.0f;
        self.searchTextField.frame = targSearchFieldRect;
        self.hashTagImageView.frame = targHashTagRect;
    }];
    
    _hashtagVisible = YES;
}

- (void)hideHashTag
{
    if (!_hashtagVisible) return;
    
    _hashtagVisible = NO;
    
    [UIView animateWithDuration:.25 animations:^{
        self.hashTagImageView.alpha = 0.0f;
        self.searchTextField.frame = initialSearchFieldFrame;
        self.hashTagImageView.frame = initialHashTagImageViewFrame;
    }];
}

@end
