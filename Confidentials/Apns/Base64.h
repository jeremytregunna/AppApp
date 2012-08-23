//
//  Base64.h
//  pmbdemo
//
//  Created by Andrejs Cernikovs on 4/8/11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Base64 : NSObject {
    
}

+(NSString *)encode:(NSData *)theData;
+ (NSData *)decode:(NSString *)theString;

@end
