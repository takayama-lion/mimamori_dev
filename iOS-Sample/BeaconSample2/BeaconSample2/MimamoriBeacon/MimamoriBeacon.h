//
//  MimamoriBeacon.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "BeaconInfo.h"

/**
 *  SampleViewControllerDelegate プロトコル
 */
@protocol BeaconDelegate <NSObject>

/**
 * serach beacon
 */
- (void)searchBeaconInfo:(BeaconInfo *)beaconInfo;

@end

@interface MimamoriBeacon : NSObject<CLLocationManagerDelegate>
{
    // 緯度
    double _latitude;
    // 経度
    double _longitude;
}

@property (nonatomic, assign) id<BeaconDelegate> delegate;

@property (strong, nonatomic) CLLocationManager *LocationManager;
@property (strong, nonatomic) CLBeaconRegion *Region;

- (id)init;
/**
 * set uuid, major
 */
- (void)setUUID:(NSString *)uuid major:(NSString *)major;
/**
 * set uuid
 */
- (void)setUUID:(NSString *)uuid;
/**
 * beacon on
 */
- (void)on;
/**
 * beacon off
 */
- (void)off;
@end
