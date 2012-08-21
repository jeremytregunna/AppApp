//
//  UIImage+SDExtensions.m
//  AppApp
//
//  Created by brandon on 8/20/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "UIImage+SDExtensions.h"

@implementation UIImage (SDExtensions)

- (NSString*)base64forImage
{
    NSData *theData = UIImagePNGRepresentation(self);
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

// rework of original by Olivier Halligon

- (UIImage*)resizedImageToSize:(CGSize)dstSize
{
	CGImageRef imgRef = self.CGImage;
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
    
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = self.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
            
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
            
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
            
		case UIImageOrientationRightMirrored: //EXIF = 7
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
            
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
	}
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, dstSize.width, dstSize.height,
                                                 8,
                                                 4 * dstSize.width,
                                                 colorSpaceRef,
                                                 kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpaceRef);
    CGRect rect = CGRectMake(0.0, 0.0, dstSize.width, dstSize.height);
    CGContextClearRect(context, rect);
    
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
    
	CGContextConcatCTM(context, transform);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, srcSize.height);
    CGContextConcatCTM(context, flipVertical);
    
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(context, CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *resizedImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(context);
    
	return resizedImage;
}

- (UIImage *)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale
{
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
    
	UIImageOrientation orient = self.imageOrientation;
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            break;
	}
    
	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
    
	if (!scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height))
		dstSize = srcSize;
    else
    {
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
        
		if (wRatio < hRatio)
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		else
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
	}
    
	return [self resizedImageToSize:dstSize];
}

@end
