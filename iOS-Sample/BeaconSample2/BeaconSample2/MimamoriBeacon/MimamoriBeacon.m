//
//  MimamoriBeacon.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "MimamoriBeacon.h"

@implementation MimamoriBeacon

- (id)init
{
    if (self = [super init]) {
        // 緯度
        _latitude = -1;
        // 経度
        _longitude = -1;
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            self.LocationManager = [[CLLocationManager alloc] init];
            self.LocationManager.delegate = self;
            if ([self.LocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
                // 位置情報の取得許可を求めるメソッド
                [self.LocationManager requestAlwaysAuthorization];
            }
        }
    }
    return self;
}
/**
 * set uuid, major
 */
- (void)setUUID:(NSString *)uuid major:(NSString *)major
{
    self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                          major:(uint16_t)[major integerValue]
                                                     identifier:[[NSUUID UUID] UUIDString]];
}
/**
 * set uuid
 */
- (void)setUUID:(NSString *)uuid
{
    self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                     identifier:[[NSUUID UUID] UUIDString]];
}
/**
 * beacon on
 */
- (void)on
{
    NSLog(@"Beacon ON");
    if ([self.LocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
        // 位置情報の取得許可を求めるメソッド
        [self.LocationManager requestAlwaysAuthorization];
    } else {
        // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
        NSLog(@"Beacon ON start monitoring");
        [self.LocationManager startMonitoringForRegion: self.Region];
    }
}
/**
 * beacon off
 */
- (void)off
{
    NSLog(@"Beacon OFF");
    [self.LocationManager stopMonitoringForRegion:self.Region];
}
// ユーザの位置情報の許可状態を確認するメソッド
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        NSLog(@"start monitoring 1");
        [self.LocationManager startMonitoringForRegion: self.Region];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        NSLog(@"start monitoring 2");
        [self.LocationManager startMonitoringForRegion: self.Region];
    }
}

// 領域計測が開始した場合
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring Region");
}

// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        // 位置情報取得
        [self.LocationManager startUpdatingLocation];
        // レンジング(Beacon の情報取得)
        [self.LocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.LocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        // 位置情報取得 終了
        [self.LocationManager stopUpdatingLocation];
        // 緯度
        _latitude = -1;
        // 経度
        _longitude = -1;
    }
}

// 領域内にいるかどうかを確認する処理
-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                NSLog(@"Enter %@",region.identifier);
                NSLog(@"Already Entering");
            }
            break;
            
        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        CLBeacon *beacon = beacons.firstObject;
        NSLog(@"UUID=%@ major=%@ minor=%@", beacon.proximityUUID, beacon.major, beacon.minor);
        if ([self.delegate respondsToSelector:@selector(searchBeaconInfo:)])
        {
            BeaconInfo *info = [[BeaconInfo alloc] init];
            info.UUID = [beacon.proximityUUID UUIDString];
            info.Major = [beacon.major stringValue];
            info.Minor = [beacon.minor stringValue];
            info.Latitude = &(_latitude);
            info.Longitude = &(_longitude);
            [_delegate searchBeaconInfo:info];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 位置情報を取り出す
    CLLocation *newLocation = [locations lastObject];
    //緯度
    _latitude = newLocation.coordinate.latitude;
    //経度
    _longitude = newLocation.coordinate.longitude;
    NSLog(@"%f", _latitude);
    NSLog(@"%f", _longitude);
    
}
@end
