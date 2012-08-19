//
//  ANImageView.m
//  AppApp
//
//  Created by brandon on 8/19/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANImageView.h"

@interface UIImage (ANImageView_Resize)
@end
@implementation UIImage (ANImageView_Resize)

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


@implementation ANImageView
{
    NSUInteger width;
    NSUInteger height;
    NSMutableURLRequest *storedRequest;
}

- (void)modifyRequest:(NSMutableURLRequest *)request
{
    // .. subclasses can override this.
    storedRequest = request;
}

- (UIImage *)modifiedImage:(UIImage *)image forResponse:(NSURLResponse *)response
{
    // scale the image down based on width.
    UIImage *resizedImage = [image resizedImageToFitInSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height) scaleIfSmaller:YES];
    
    // since we hate resizing things... lets try an shove it in the cache for next time
    // its requested...
    
    // fyi, we are too fucking clever for our own good.
    NSURLCache *cache = [NSURLCache sharedURLCache];
    NSData *resizedData = UIImagePNGRepresentation(resizedImage); // thred-safe despite the UI moniker.
    NSCachedURLResponse *fakeResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:resizedData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    [cache storeCachedResponse:fakeResponse forRequest:storedRequest];
    
    return resizedImage;
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
