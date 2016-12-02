//
//  MimamoriBeacon.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "MimamoriBeacon.h"
#import <AudioToolbox/AudioServices.h>

NSString *const RUNNING_STATE = @"running";

@implementation MimamoriBeacon

/**
 * init
 */
- (id)initIdentifier:(NSString *)identifier;
{
    if (self = [super init]) {
        self.Identifier = identifier;
        _isRange = false;
        _BeaconList = [NSMutableArray array];
    }
    return self;
}
/**
 * set uuid, major, minor
 */
- (void)setUUID:(NSString *)uuid major:(NSString *)major minor:(NSString *)minor
{
    if ([major length]) {
        if ([minor length]) {
            self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                                  major:(uint16_t)[major integerValue]
                                                                  minor:(uint16_t)[minor integerValue]
                                                             identifier:self.Identifier];
            self.Region.notifyOnEntry = YES;
            self.Region.notifyOnExit = YES;
            self.Region.notifyEntryStateOnDisplay = NO;
            
        } else {
            [self setUUID:uuid major:minor];
            
        }
    } else {
        [self setUUID:uuid];
        
    }

}
/**
 * set uuid, major
 */
- (void)setUUID:(NSString *)uuid major:(NSString *)major
{
    if ([major length]) {
        self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                              major:(uint16_t)[major integerValue]
                                                         identifier:self.Identifier];
        self.Region.notifyOnEntry = YES;
        self.Region.notifyOnExit = YES;
        self.Region.notifyEntryStateOnDisplay = NO;
        
    } else {
        [self setUUID:uuid];
    }
}
/**
 * set uuid
 */
- (void)setUUID:(NSString *)uuid
{
    self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid]
                                                     identifier:self.Identifier];
    self.Region.notifyOnEntry = YES;
    self.Region.notifyOnExit = YES;
    self.Region.notifyEntryStateOnDisplay = NO;
}
/**
 * beacon on
 */
- (void)on
{
    NSLog(@"Beacon ON");
    if ([self isRunning]) {
        [self off];
    }
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
        } else {
            // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
            NSLog(@"Beacon ON start monitoring");
            [self.LocationManager startMonitoringForRegion: self.Region];
            [self stateON];
        }
    }
}
/**
 * beacon off
 */
- (void)off
{
    NSLog(@"Beacon OFF");
    for (CLBeaconRegion *region in [self.LocationManager monitoredRegions]) {
        [self.LocationManager stopMonitoringForRegion:region];
        NSLog(@"--region=%@", region);
    }
//    NSLog(@"regions:[%@]", regions);
    [self.LocationManager stopMonitoringForRegion:self.Region];
    self.LocationManager.delegate = nil;
    [self stateOFF];
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
        [self stateON];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        NSLog(@"start monitoring 2");
        [self.LocationManager startMonitoringForRegion: self.Region];
        [self stateON];
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
    [_delegate searchBeaconInfo:[NSString stringWithFormat:@"***** beacon in *****\n%@\n%@", region, [NSDate date]] title:@"Beacon IN"];

    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        AudioServicesPlaySystemSound(10000);
        _isRange = true;
        // 位置情報取得
        [self.LocationManager requestLocation];
        // レンジング(Beacon の情報取得)
        [self.LocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Region");
    [_delegate searchBeaconInfo:[NSString stringWithFormat:@"***** beacon out *****\n%@\n%@", region, [NSDate date]] title:@"Beacon OUT"];
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        _isRange = false;
        // レンジング(Beacon の情報取得)
        [self.LocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
//        [self.LocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        // 位置情報取得
//        [self.LocationManager requestLocation];
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
                // 位置情報取得
                [self.LocationManager startUpdatingLocation];
                // レンジング(Beacon の情報取得)
                [self.LocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
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
    NSString *message = @"";
    BOOL isflg = false;
    for (NSInteger i=0; i<beacons.count; i++) {
        CLBeacon *beacon = [beacons objectAtIndex:i];
        NSLog(@"UUID=%@ major=%@ minor=%@", beacon.proximityUUID, beacon.major, beacon.minor);
        if ([self.delegate respondsToSelector:@selector(searchBeaconInfo:title:)])
        {
            NSString *uuid = [beacon.proximityUUID UUIDString];
            NSString *major = [beacon.major stringValue];
            NSString *minor = [beacon.minor stringValue];
            
            if (_BeaconList.count == 0) {
                BeaconInfo *info = [[BeaconInfo alloc] init];
                info.UUID = uuid;
                info.Major = major;
                info.Minor = minor;
                info.Latitude = &(_latitude);
                info.Longitude = &(_longitude);
                message = [NSString stringWithFormat:@"%@\n\n UUID=%@\n Major=%@\n Minor=%@\n Latitude=%f\n Longitude=%f\n%@", message, info.UUID, info.Major, info.Minor, *info.Latitude, *info.Longitude, [NSDate date]];
                [_BeaconList addObject:info];
                isflg = true;
            }
            for (NSInteger i=0; i<_BeaconList.count; i++) {
                BeaconInfo *inf = [_BeaconList objectAtIndex:i];
                if (![inf.UUID isEqualToString:uuid] || ![inf.Major isEqualToString:major] || ![inf.Minor isEqualToString:minor]) {
                    [_BeaconList addObject:inf];
                    BeaconInfo *info = [[BeaconInfo alloc] init];
                    info.UUID = uuid;
                    info.Major = major;
                    info.Minor = minor;
                    info.Latitude = &(_latitude);
                    info.Longitude = &(_longitude);
                    message = [NSString stringWithFormat:@"%@\n\n UUID=%@\n Major=%@\n Minor=%@\n Latitude=%f\n Longitude=%f\n%@", message, info.UUID, info.Major, info.Minor, *info.Latitude, *info.Longitude, [NSDate date]];
                    isflg = true;
                }
            }
            
        }
    }
    if (isflg) {
        [_delegate isBeacon:YES];
        [_delegate searchBeaconInfo:message title:@"detail"];
        
        // 10秒間ほど連続で同じ通知が出ないようにする
        if (_timer == nil) {
            NSLog(@"--timer on");
            _timer = [NSTimer scheduledTimerWithTimeInterval:15
                                                      target:self
                                                    selector:@selector(time:)
                                                    userInfo:nil
                                                     repeats:NO];
        }
    } else {
        NSLog(@"---no region");
        if (!_isRange) {
            [self.LocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
            [_delegate isBeacon:NO];
        }

    }
}
- (void)time:(NSTimer*)timer
{
    NSLog(@"--timer off");
    [_BeaconList removeAllObjects];
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
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
    // 位置情報取得 終了
    [self.LocationManager stopUpdatingLocation];
}
/**
 * beacon running state on
 */
- (void)stateON
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setBool:YES forKey:RUNNING_STATE];
    [pref synchronize];
}
/**
 * beacon running state off
 */
- (void)stateOFF
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:RUNNING_STATE];
    [pref synchronize];
}
/**
 * is beacon running state
 */
- (BOOL)isRunning
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref boolForKey:RUNNING_STATE];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"------error");
}
@end
