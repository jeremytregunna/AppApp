//
//  ANImageView.m
//  AppApp
//
//  Created by brandon on 8/19/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANImageView.h"

@implementation ANImageView
{
    NSUInteger width;
    NSUInteger height;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(CGFloat)width
{
    CGFloat oldWidth = sourceImage.size.width;
    CGFloat scaleFactor = width / oldWidth;
    
    CGFloat newHeight = sourceImage.size.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setImage:(UIImage *)image
{
    CGSize size = image.size;
    // we really prefer width to anything else..
    if (size.width != width)
    {
        image = [ANImageView imageWithImage:image scaledToWidth:width];
    }
    [super setImage:image];
}

- (void)setImageURL:(NSString *)value
{
    CGSize size = self.bounds.size;
    width = size.width;
    height = size.height;
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
