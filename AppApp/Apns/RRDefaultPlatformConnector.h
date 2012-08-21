//
//  GCDefaultPlatformConnector.h
//  pmbdemo
//
//  Created by Andrejs Cernikovs on 4/7/11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//

#import "RRPlatformConnector.h"
#import "RRDeviceMetadata.h"

@interface RRDefaultPlatformConnector : NSObject <RRPlatformConnector> {
    
    __weak id<RRPlatformConnectorDelegate>		delegate;
    
    NSString*                           apiKey;
    NSString*                           apiSecret;
    
    RRDeviceMetadata*                   deviceMetadata;
    
    NSURLConnection*					connection;
}

@property(weak) id<RRPlatformConnectorDelegate> delegate;
@property(nonatomic, retain) RRDeviceMetadata* deviceMetadata;

- (RRDefaultPlatformConnector *) initWithApiKey:(NSString *)_apiKey withApiSecret:(NSString *)_apiSecret;
- (void) asyncRegisterDevice:(RRDeviceMetadata *)_deviceMetadata;

@end
