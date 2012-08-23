//
//  GCDefaultPlatformConnector.m
//  pmbdemo
//
//  Created by Andrejs Cernikovs on 4/7/11.
//  Copyright 2011 GrandCentrix. All rights reserved.
//

#import "RRDefaultPlatformConnector.h"
#import "Base64.h"
#import "RRConstants.h"

@interface RRDefaultPlatformConnector (Private)

- (void)releaseConnection;
- (void)authenticateRequest:(NSMutableURLRequest *)_request;

@end

@implementation RRDefaultPlatformConnector
@synthesize delegate, deviceMetadata;

- (RRDefaultPlatformConnector *) initWithApiKey:(NSString *)_apiKey withApiSecret:(NSString *)_apiSecret
{
    if ((self = [super init]) != nil) {
        apiKey = _apiKey;
        apiSecret = _apiSecret;
	}
	return self;
    
}

- (void)asyncRegisterDevice:(RRDeviceMetadata *)_deviceMetadata
{
    self.deviceMetadata = _deviceMetadata;
    
    NSString *_endpointUrl = [NSString stringWithFormat: @"%@/device_tokens/%@", RR_PLATFORM_URL, _deviceMetadata.deviceToken];
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_endpointUrl]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60.0];
    [_request setHTTPMethod:@"PUT"];
    [_request addValue:@"application/json;charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    [_request setHTTPBody: [[_deviceMetadata asJsonString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self authenticateRequest:_request];
    
    connection = [[NSURLConnection alloc]
                  initWithRequest:_request
                  delegate:self
                  startImmediately:YES];
    
    
}

- (void)asyncAssociateUser:(NSString *)_userId withDeviceId:(NSString *)_deviceId andAccessToken:(NSString *)_authToken
{    
    NSString *_endpointUrl = [NSString stringWithFormat: @"%@/user/%@/device/%@", RR_PLATFORM_URL, _userId, _deviceId];
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_endpointUrl]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60.0];
    [_request setHTTPMethod:@"PUT"];
    [_request addValue:@"application/json;charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    
    [self authenticateRequest:_request];
    
    connection = [[NSURLConnection alloc]
                  initWithRequest:_request
                  delegate:self
                  startImmediately:YES];
    
    
    NSString *_endpointUrlCloud = [NSString stringWithFormat: @"%@/hello/%@/%@/%@.json", RR_APPAPP_CLOUD_URL, _userId, _authToken, _deviceId];
    
    NSMutableURLRequest *_requestCloud = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_endpointUrlCloud]
                                                            cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60.0];
    [_requestCloud setHTTPMethod:@"PUT"];
    [_requestCloud addValue:@"application/json;charset=utf-8" forHTTPHeaderField: @"Content-Type"];
    [_requestCloud addValue:RR_APPAPP_CLOUD_API_KEY forHTTPHeaderField: @"X-APPAPPCLOUD-KEY"];
    [_requestCloud addValue:RR_APPAPP_CLOUD_API_SECRET forHTTPHeaderField: @"X-APPAPPCLOUD-SECRET"];

    connection = [[NSURLConnection alloc]
                  initWithRequest:_requestCloud
                  delegate:self
                  startImmediately:YES];
}

- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)_error
{
	
    [delegate didRegistrationFail:deviceMetadata withError:_error];
    [self releaseConnection];
}


- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSHTTPURLResponse *)_response
{
    
    switch ([_response statusCode]) {
        case 200:
            if([delegate respondsToSelector:@selector(didRegistrationFinish:)]){
                [delegate didRegistrationFinish:deviceMetadata];
            }
            break;
        case 201:
            if([delegate respondsToSelector:@selector(didRegistrationFinish:)]){
                [delegate didRegistrationFinish:deviceMetadata];
            }
            break;
        default:
            if([delegate respondsToSelector:@selector(didRegistrationFail:withError:)]){
                NSMutableDictionary *_errorDetail = [NSMutableDictionary dictionary];
                [_errorDetail setValue:[NSHTTPURLResponse localizedStringForStatusCode:[_response statusCode]]
                                forKey:NSLocalizedDescriptionKey];
                
                NSError *_error = [NSError errorWithDomain:@"pmb" code:[_response statusCode] userInfo:_errorDetail];
                [delegate didRegistrationFail:deviceMetadata withError:_error];
                break;
            }
    }
    
    [self releaseConnection];
}

#pragma mark -
#pragma mark Private Methods

- (void)authenticateRequest:(NSMutableURLRequest *)_request
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", apiKey, apiSecret];
    
    // employ the Base64 encoding above to encode the authentication tokens
    NSString *encodedLoginData = [Base64 encode:[authStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
    [_request setValue:authValue forHTTPHeaderField:@"Authorization"];
}

- (void)releaseConnection
{
    if (connection) {
        [connection cancel];
        connection = nil;
    }
}

@end
