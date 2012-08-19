//
//  ANPostLabel.h
//  AppApp
//
//  Created by brandon on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "DTAttributedTextContentView.h"

@interface ANPostLabel : DTAttributedTextContentView<DTAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSDictionary *postData;
@property (nonatomic, assign) BOOL enableLinks;
@property (readwrite, nonatomic, copy) BOOL (^tapHandler)(NSString *type, NSString *value);

@end
