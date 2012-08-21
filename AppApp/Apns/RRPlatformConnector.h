//
//  GCPlatformConnector.h
//  pmbdemo
//
//  Created by Andrejs Cernikovs on 4/7/11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//

#import "RRPlatformConnectorDelegate.h"

@protocol RRPlatformConnector <NSObject>

@property(weak) id<RRPlatformConnectorDelegate> delegate;

- (id<RRPlatformConnector>) initWithApiKey:(NSString *)_apiKey withApiSecret:(NSString *)_apiSecret;
- (void) asyncRegisterDevice:(RRDeviceMetadata *)_deviceMetadata;

@end
