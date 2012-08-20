//
//  ANImageView.m
//  AppApp
//
//  Created by brandon on 8/19/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANImageView.h"
#import "UIImage+SDExtensions.h"

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
