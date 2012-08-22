//
//  RRDeviceMetadata.h
//
//  Created by Ralf Rottmann.
//

@interface RRDeviceMetadata : NSObject {
    
    NSString*                   deviceToken;
    NSString*                   deviceId;
    NSString*                   deviceName;
    NSString*                   deviceModel;
    NSString*                   systemName;
    NSString*                   systemVersion;
    
    NSArray*                    tags;
    
}

@property(nonatomic, retain)NSString *deviceToken;
@property(nonatomic, retain)NSString *deviceId;
@property(nonatomic, retain)NSString *deviceName;
@property(nonatomic, retain)NSString *deviceModel;
@property(nonatomic, retain)NSString *systemName;
@property(nonatomic, retain)NSString *systemVersion;
@property(nonatomic, retain)NSArray *tags;


- (RRDeviceMetadata *) initWithDeviceToken:(NSString *)_deviceToken withDeviceId:(NSString *)_deviceId;
- (NSString *) asJsonString;
@end
