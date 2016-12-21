//
//  IBeaconInfo.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/12/19.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "IBeaconInfo.h"

@implementation IBeaconInfo

/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major
           minor:(NSString *)minor
        latitude:(double)latitude
       longitude:(double)longitude
          status:(NSString *)status
{
    IBeaconInfo *beaconInfo = [[IBeaconInfo alloc] init];
    beaconInfo.UUID      = uuid;
    beaconInfo.Major     = major;
    beaconInfo.Minor     = minor;
    beaconInfo.Latitude  = latitude;
    beaconInfo.Longitude = longitude;
    beaconInfo.Status    = status;
    return beaconInfo;
}
/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major
           minor:(NSString *)minor
          status:(NSString *)status
{
    IBeaconInfo *beaconInfo = [[IBeaconInfo alloc] init];
    beaconInfo.UUID      = uuid;
    beaconInfo.Major     = major;
    beaconInfo.Minor     = minor;
    beaconInfo.Status    = status;
    return beaconInfo;
}
/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major
{
    IBeaconInfo *beaconInfo = [[IBeaconInfo alloc] init];
    beaconInfo.UUID      = uuid;
    beaconInfo.Major     = major;
    return beaconInfo;
}
/**
 * set latitude longitude
 */
- (void)setLatitude:(double)latitude longitude:(double)longitude
{
    self.Latitude  = latitude;
    self.Longitude = longitude;
}
/**
 * beacon
 * param beaconInfo:(IBeaconInfo *)
 */
- (BOOL)isEqual:(IBeaconInfo *)beaconInfo
{
    if ([_UUID isEqualToString:beaconInfo.UUID]
        && [_Major isEqualToString:beaconInfo.Major]
        && [_Minor isEqualToString:beaconInfo.Minor]) {
        return true;
    }
    return false;
}
/**
 * is status
 * return true:IN false:OUT
 */
- (BOOL)isStatus
{
    if ([_Status isEqualToString:BEACON_STATUS_ON]) {
        return true;
    } else {
        return false;
    }
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    if (self)
    {
        // ここで aDecoder に格納しておいた値を取得します。
        _UUID = [aDecoder decodeObjectForKey:@"uuid"];
        _Major = [aDecoder decodeObjectForKey:@"major"];
        _Minor = [aDecoder decodeObjectForKey:@"minor"];
        _Latitude = [aDecoder decodeFloatForKey:@"latitude"];
        _Longitude = [aDecoder decodeFloatForKey:@"longitude"];
        _Status = [aDecoder decodeObjectForKey:@"status"];
    }
    
    return self;
}

// 変換用メソッド（NSData への変換で使用）
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:_UUID forKey:@"uuid"];
    [aCoder encodeObject:_Major forKey:@"major"];
    [aCoder encodeObject:_Minor forKey:@"minor"];
    [aCoder encodeFloat:_Latitude forKey:@"latitude"];
    [aCoder encodeFloat:_Longitude forKey:@"longitude"];
    [aCoder encodeObject:_Status forKey:@"status"];
}
@end
