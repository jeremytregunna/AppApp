//
//  ANReadLaterAuthViewController.h
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-22.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANReadLaterManager.h"

@interface ANReadLaterAuthViewController : UIViewController <UITextFieldDelegate>
- (id)initWithServiceType:(ANReadLaterType)type failedURL:(NSURL*)url manager:(ANReadLaterManager*)manager;
@end
