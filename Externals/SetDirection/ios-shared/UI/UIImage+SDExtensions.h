//
//  UIImage+SDExtensions.h
//  AppApp
//
//  Created by brandon on 8/20/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SDExtensions)

- (NSString *)base64forImage;
- (UIImage *)resizedImageToSize:(CGSize)dstSize;
- (UIImage *)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;

@end
