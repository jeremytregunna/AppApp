//
//  GCPlatformConnectorDelegate.h
//  pmbdemo
//
//  Created by Andrejs Cernikovs on 4/8/11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//

#import "RRDeviceMetadata.h"

@protocol RRPlatformConnectorDelegate <NSObject>

@optional

- (void) didRegistrationFail:(RRDeviceMetadata *)_metadata withError:(NSError *)_error;
- (void) didRegistrationFinish:(RRDeviceMetadata *)_metadata;


@end
