//
//  ANImageView.m
//  AppApp
//
//  Created by brandon on 8/19/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANImageView.h"

@implementation ANImageView

- (void)setImageURL:(NSString *)value
{
    CGSize size = self.bounds.size;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    NSMutableString *sizedValue = [value mutableCopy];
    if (size.width > 0 && size.height > 0)
    {
        if ([sizedValue rangeOfString:@"?"].location == NSNotFound)
            [sizedValue appendFormat:@"?w=%u&h=%u", width, height];
        else
            [sizedValue appendFormat:@"&w=%u&h=%u", width, height];
        [super setImageURL:sizedValue];
    }
    else
        [super setImageURL:value];
}

@end
