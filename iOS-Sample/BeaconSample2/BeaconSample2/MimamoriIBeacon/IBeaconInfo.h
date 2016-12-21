//
//  IBeaconInfo.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/12/19.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BEACON_STATUS_ON @"ON"
#define BEACON_STATUS_OUT @"OUT"

@interface IBeaconInfo : NSObject<NSCoding>

@property (nonatomic) NSString *UUID;
@property (nonatomic) NSString *Major;
@property (nonatomic) NSString *Minor;
@property (nonatomic) double Latitude;
@property (nonatomic) double Longitude;
@property (nonatomic) NSString *Status;

/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major
           minor:(NSString *)minor
        latitude:(double)latitude
       longitude:(double)longitude
          status:(NSString *)status;
/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major
           minor:(NSString *)minor
          status:(NSString *)status;
/**
 * create beacon info
 */
+ (id)createUUID:(NSString *)uuid
           major:(NSString *)major;
/**
 * set latitude longitude
 */
- (void)setLatitude:(double)latitude longitude:(double)longitude;
/**
 * beacon
 * param beaconInfo:(IBeaconInfo *)
 */
- (BOOL)isEqual:(IBeaconInfo *)beaconInfo;
/**
 * is status
 * return true:IN false:OUT
 */
- (BOOL)isStatus;
@end
