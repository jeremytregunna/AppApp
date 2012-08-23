//
//  RRDeviceMetadata.m
//
//  Created by Ralf Rottmann..

//

#import "RRDeviceMetadata.h"
#import "NSObject+SBJSON.h"

@implementation RRDeviceMetadata
@synthesize deviceToken, deviceId, deviceName, deviceModel, systemName, systemVersion, tags;

- (RRDeviceMetadata *) initWithDeviceToken:(NSString *)_deviceToken withDeviceId:(NSString *)_deviceId{
	if ((self = [super init]) != nil) {
		self.deviceToken = _deviceToken;
        self.deviceId = _deviceId;
	}
	return self;
}

- (NSString *) asJsonString{
    NSMutableDictionary *_d = [NSMutableDictionary dictionaryWithCapacity:5];
    [_d setValue:deviceId forKey:@"device_id"];
    [_d setValue:deviceName forKey:@"device_name"];
    [_d setValue:deviceModel forKey:@"device_model"];
    [_d setValue:systemName forKey:@"system_name"];
    [_d setValue:systemVersion forKey:@"system_version"];
    [_d setValue:tags forKey:@"tags"];
    return [_d JSONRepresentation];
    
}

@end
