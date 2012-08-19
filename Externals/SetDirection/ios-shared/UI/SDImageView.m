//
//  SDImageView.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "SDImageView.h"
#import "SDURLConnection.h"

@implementation SDImageView
{
    __weak SDURLConnection *urlConnection;
    NSString *imageURL;
}

@synthesize imageURL;

- (void)modifyRequest:(NSMutableURLRequest *)request
{
    // .. subclasses can override this.
}

- (UIImage *)modifiedImage:(UIImage *)image forResponse:(NSURLResponse *)response
{
    // must be thred-safe!!
    return image;
}

- (void)setImageURL:(NSString *)value
{
    imageURL = value;
    if (urlConnection)
        [urlConnection cancel];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:value]];
    [self modifyRequest:request];
    urlConnection = [SDURLConnection sendAsynchronousRequest:request shouldCache:YES withResponseHandler:^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error) {
        UIImage *newImage = [UIImage imageWithData:responseData];
        UIImage *modifiedImage = [self modifiedImage:newImage forResponse:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = modifiedImage;
            self.backgroundColor = [UIColor clearColor];
            urlConnection = nil;
        });
    }];
}

@end
