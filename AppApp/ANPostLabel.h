//
//  ANPostLabel.h
//  AppApp
//
//  Created by brandon on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "CCoreTextLabel.h"

@interface ANPostLabel : CCoreTextLabel

@property (nonatomic, strong) NSDictionary *postData;
@property (readwrite, nonatomic, copy) BOOL (^tapHandler)(NSRange, NSString *, NSString *type);

@end
