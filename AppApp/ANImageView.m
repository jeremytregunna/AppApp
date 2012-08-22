/*
 Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman
 The AppApp source code is distributed under the The MIT License (MIT) license.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 Any end-user product or application build based on this code, must include the following acknowledgment:
 
 "This product includes software developed by the original AppApp team and its contributors", in the software
 itself, including a link to www.app-app.net.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
*/

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

- (NSUInteger)scaleFactor
{
    return (NSUInteger)[UIScreen mainScreen].scale;
}

- (UIImage *)modifiedImage:(UIImage *)image forResponse:(NSURLResponse *)response
{
    // scale the image down based on width.
    UIImage *resizedImage = [image resizedImageToFitInSize:CGSizeMake(self.bounds.size.width * self.scaleFactor, self.bounds.size.height * self.scaleFactor) scaleIfSmaller:YES];
    
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
            [sizedValue appendFormat:@"?w=%u&h=%u", width * self.scaleFactor, height * self.scaleFactor];
        else
            [sizedValue appendFormat:@"&w=%u&h=%u", width * self.scaleFactor, height * self.scaleFactor];
        [super setImageURL:sizedValue];
    }
    else
        [super setImageURL:value];
}

@end
