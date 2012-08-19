//
//  NSDate+ANExtensions.m
//  AppApp
//
//  Created by brandon on 8/16/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "NSDate+ANExtensions.h"

@implementation NSDate (ANExtensions)

- (NSString *)stringInterval
{
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the current date
    NSDate *currentDate = [[NSDate alloc] init];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:currentDate  toDate:self  options:0];
    
    //NSLog(@"Break down: %dmin %dhours %ddays %dmoths",[breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    
    NSString *intervalString;
    if ([breakdownInfo month]) {
        if (-[breakdownInfo month] > 1)
            intervalString = [NSString stringWithFormat:@"%dM", -[breakdownInfo month]];
        else
            intervalString = @"1M";
    }
    else if ([breakdownInfo day]) {
        if (-[breakdownInfo day] > 1)
            intervalString = [NSString stringWithFormat:@"%dd", -[breakdownInfo day]];
        else
            intervalString = @"1d";
    }
    else if ([breakdownInfo hour]) {
        if (-[breakdownInfo hour] > 1)
            intervalString = [NSString stringWithFormat:@"%dh", -[breakdownInfo hour]];
        else
            intervalString = @"1h";
    }
    else {
        if (-[breakdownInfo minute] > 1)
            intervalString = [NSString stringWithFormat:@"%dm", -[breakdownInfo minute]];
        else
            intervalString = @"1m";
    }
    
    return intervalString;
}
@end
