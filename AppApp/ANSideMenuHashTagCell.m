//
//  ANSideMenuHashTagCell.m
//  AppApp
//
//  Created by protozog on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANSideMenuHashTagCell.h"

@implementation ANSideMenuHashTagCell

- (IBAction)closeButtonPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(didSelectCloseButtonWithCell:)]) {
        [_delegate didSelectCloseButtonWithCell:self];
    }
}

@end
