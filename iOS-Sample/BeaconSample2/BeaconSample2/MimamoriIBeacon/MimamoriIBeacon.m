//
//  MimamoriIBeacon.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/12/19.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "MimamoriIBeacon.h"

#define BEACON_AREA_LIST @"beacon_area_list_"
#define BEACON_SAVE_LIST @"beacon_save_list_"
#define BEACON_IDENTIFIER @"beacon_identifer_"
#define BEACON_OUTPUT @"beacon_output_"
#define BEACON_ON_TIME @"beacon_on_time_"

@implementation MimamoriIBeacon

/**
 * init
 * param (NSString *)menuId'
 */
- (id)initWithMenuId:(NSString *)menuId
{
    if (self = [super init]) {
        self.MenuId = menuId;
        _regionList = [NSMutableDictionary dictionary];

    }
    return self;
}
/**
 * init
 * param (NSString *)menuId'
 * param (NSString *)uuid
 */
- (id)initWithMenuId:(NSString *)menuId uuid:(NSString *)uuid
{
    if (self = [super init]) {
        self.UUID = uuid;
        self.MenuId = menuId;
        _regionList = [NSMutableDictionary dictionary];
        
    }
    return self;
}
/**
 * set area id
 * param:(NSMutableArray *)areaLists
 */
- (void)setAreaLists:(NSMutableArray *)areaLists
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:areaLists forKey:[self getKey:BEACON_AREA_LIST]];
    [pref synchronize];
}
/**
 * on
 */
- (void)on
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        // 一時保存データ削除
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref removeObjectForKey:[self getKey:BEACON_SAVE_LIST]];
        [pref synchronize];
        
        self.LocationManager = [[CLLocationManager alloc] init];
        self.LocationManager.delegate = self;
        if ([self.LocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
            // 位置情報の取得許可を求めるメソッド
            [self.LocationManager requestAlwaysAuthorization];
        } else {
            // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
            NSLog(@"Beacon ON start monitoring");
            [self startMonitoring];
        }
    }
}
/**
 * off
 */
- (void)off
{
    NSLog(@"Beacon OFF");
    for (CLBeaconRegion *region in [self.LocationManager monitoredRegions]) {
        [self.LocationManager stopMonitoringForRegion:region];
        NSLog(@"--region=%@", region);
    }
    self.LocationManager.delegate = nil;

    // 保持一覧削除
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:[self getKey:BEACON_ON_TIME]];
    [pref synchronize];
}
/**
 * start monitaring
 */
- (void)startMonitoring
{
    // すでに登録している設定値がある場合を考え、停止処理を入れる
    for (CLBeaconRegion *region in [self.LocationManager monitoredRegions]) {
        [self.LocationManager stopMonitoringForRegion:region];
        NSLog(@"--region=%@", region);
    }

    // region 設定
    self.Region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.UUID]
                                                                identifier:[self getKey:BEACON_IDENTIFIER]];
    self.Region.notifyOnEntry = YES;
    self.Region.notifyOnExit = YES;
    self.Region.notifyEntryStateOnDisplay = NO;

    // 設定値一覧登録
    [self.LocationManager startMonitoringForRegion:self.Region];

    // 起動時間を保持する
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSDate date] forKey:[self getKey:BEACON_ON_TIME]];
    [pref synchronize];

}
/**
 * is running
 * return:(BOOL)
 */
- (BOOL)isRunning
{
    if ([[self.LocationManager monitoredRegions] count] > 0) {
        return true;
    }
    return false;
}
/**
 * is timeout
 * return:(BOOL)
 */
- (BOOL)isTimeOut
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSDate *anyDate = [pref objectForKey:[self getKey:BEACON_ON_TIME]];
    if (anyDate == nil) {
        return false;
    }
    
    NSDate *now = [NSDate date];
    float diff = [now timeIntervalSinceDate:anyDate];
    if (diff > _TimeOut) {
        return false;
    } else {
        return true;
    }
}
/**
 * ユーザの位置情報の許可状態を確認するメソッド
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        NSLog(@"start monitoring 1");
        [self startMonitoring];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        NSLog(@"start monitoring 2");
        [self startMonitoring];
    }
}
/**
 * 領域計測が開始した場合
 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring Region");
    if (_areaList == nil) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        _areaList = [pref objectForKey:[self getKey:BEACON_AREA_LIST]];
    }
}
/**
 * 指定した領域に入った場合
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Enter Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        // レンジング(Beacon の情報取得)
        [self.LocationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}
/**
 * 指定した領域から出た場合
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exit Region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        // Beacon機器が全て域外に出たので、現在保存している一覧は全てOUTになったと判断
        // output一覧に追加する
        [self addIBeaconList:[self loadIBeaconListForKey:[self getKey:BEACON_SAVE_LIST]] forKey:[self getKey:BEACON_OUTPUT]];
        // 検出一覧データを削除する。
        [self clearIBeaconListForKey:[self getKey:BEACON_SAVE_LIST]];
        
        // beacon range stop
        [self.LocationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];

        // 位置情報取得
        [self.LocationManager requestLocation];
    }
}
/**
 * 領域内にいるかどうかを確認する処理
     */
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
/**
 * Beacon信号を検出した場合
 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    // 新規検出Beacon一覧削除
    NSMutableDictionary *inBeaconList = [NSMutableDictionary dictionary];

    // 検出Beacon一覧をload
    NSMutableDictionary *beaconTempList = [self loadIBeaconListForKey:[self getKey:BEACON_SAVE_LIST]];

    // Beacon機器一覧取得用
    NSMutableDictionary *newBeaconList = [NSMutableDictionary dictionary];
    for (CLBeacon *beacon in beacons) {
        NSString *major = [beacon.major stringValue];
        // 登録 ariaIDが無ければcontinue
        if (![_areaList containsObject:major]) {
            continue;
        }
        NSString *uuid = [beacon.proximityUUID UUIDString];
        NSString *minor = [beacon.minor stringValue];
        NSLog(@"----beacin[%@][%@]", major, minor);
        // 新しいリストに追加
        IBeaconInfo *beaconInfo = [IBeaconInfo createUUID:uuid major:major minor:minor status:BEACON_STATUS_ON];
        NSString *key = [NSString stringWithFormat:@"%@-%@", major, minor];
        [newBeaconList setObject:beaconInfo forKey:key];
        // 登録済みなら古い方を削除する
        if ([beaconTempList objectForKey:key] != nil) {
            [beaconTempList removeObjectForKey:key];
        } else {
            // 未保存データなら新規追加一覧に追加する。
            [inBeaconList setObject:beaconInfo forKey:key];
        }
    }
    // 検出したBeacon一覧を保存
    if (![self saveIBeaconList:newBeaconList forKey:[self getKey:BEACON_SAVE_LIST]]) {
        // 保存するデータが存在しない場合データを削除する。
        [self clearIBeaconListForKey:[self getKey:BEACON_SAVE_LIST]];
    }
    
    BOOL isOutput = false;
    // 新規にINした一覧
    if ([inBeaconList count] > 0) {
        for (id key in [inBeaconList keyEnumerator]) {
            IBeaconInfo *info = [inBeaconList objectForKey:key];
            NSLog(@"---- in beacon[%@][%@]", info.Major, info.Minor);
        }
        // output 一覧に追加
        [self addIBeaconList:inBeaconList forKey:[self getKey:BEACON_OUTPUT]];
        isOutput = true;
    }
    // OUTになった一覧(ステータスをOUT)に設定
    if (beaconTempList != nil && [beaconTempList count] > 0) {
        for (id key in [beaconTempList keyEnumerator]) {
            IBeaconInfo *info = [beaconTempList objectForKey:key];
            info.Status = BEACON_STATUS_OUT;
            NSLog(@"---- out beacon[%@][%@]", info.Major, info.Minor);
        }
        // output 一覧に追加
        [self addIBeaconList:beaconTempList forKey:[self getKey:BEACON_OUTPUT]];
        isOutput = true;
    }
    if (isOutput) {
        // 位置情報取得
        [self.LocationManager requestLocation];
    }
}
/**
 * 位置情報取得
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 位置情報を取り出す
    CLLocation *newLocation = [locations lastObject];
    
    //緯度
    float latitude = newLocation.coordinate.latitude;
    //経度
    float longitude = newLocation.coordinate.longitude;

    // 一覧取得
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *list =[self loadIBeaconListForKey:[self getKey:BEACON_OUTPUT]];
    for (id key in [list keyEnumerator]) {
        IBeaconInfo *info = [list objectForKey:key];
        info.Latitude = latitude;
        info.Longitude = longitude;
        [array addObject:info];
        NSLog(@"----output -Major[%@] Minor[%@] latitude[%f] longitude[%f] status[%@]", info.Major, info.Minor, latitude, longitude, info.Status);
    }
    [self clearIBeaconListForKey:[self getKey:BEACON_OUTPUT]];
    // 取得した一覧を渡す
    if ([array count] > 0) {
        if ([self.delegate respondsToSelector:@selector(getOutputBeacons:)]) {
            [self.delegate getOutputBeacons:array];
        }
    }
}
/**
 * 位置情報取得エラー
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"------error");
}
/**
 * 保存キーを key_<menuId>で生成する
 * return (NSString *)
 */
- (NSString *)getKey:(NSString *)prefKey
{
    return [prefKey stringByAppendingString:self.MenuId];
}
/**
 * IBeaconInfo一覧を保存する
 * param (NSMutableDictionary *)list
 * param (NSString *)key
 * return saved:true / not data exist:false
 */
- (BOOL)saveIBeaconList:(NSMutableDictionary *)list forKey:(NSString *)key
{
    if (list == nil || [list count] == 0) {
        return false;
    }
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list];
    [pref setObject:data forKey:key];
    [pref synchronize];
    return true;
}
/**
 * IBeaconInfo一覧を取得する
 * 値がnilの場合はNSMutableDictionaryのインスタンスを生成出力する。
 * param (NSString *)key
 */
- (NSMutableDictionary *)loadIBeaconListForKey:(NSString *)key
{
    NSMutableDictionary *list = nil;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSData * data = [pref objectForKey:key];
    if (data != nil) {
        list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (list == nil) {
        list = [NSMutableDictionary dictionary];
    }
    // debug start
    for (id key in [list keyEnumerator]) {
        IBeaconInfo *info = [list objectForKey:key];
        NSLog(@"---load- key=[%@], major=[%@] minor=[%@]", key, info.Major, info.Minor);
    }
    // debug end
    return list;
}
/**
 * IBeaconInfo一覧を削除する
 * param (NSString *)key
 */
- (void)clearIBeaconListForKey:(NSString *)key
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:key];
    [pref synchronize];
}
/**
 * 保存しているIBeaconInfo一覧に一覧を追加して保存する
 * param (NSMutableArray *)list
 * param (NSString *)key
 * return saved:true / not add data:false
 */
- (BOOL)addIBeaconList:(NSMutableDictionary *)list forKey:(NSString *)key
{
    if (list == nil || [list count] == 0) {
        return false;
    }
    NSMutableDictionary *oldlist = nil;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSData * data = [pref objectForKey:key];
    if (data != nil) {
        oldlist = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    // 保存データが存在する
    // oldlistが存在するならリストを結合する
    if (oldlist != nil && [oldlist count] > 0) {
        [oldlist addEntriesFromDictionary:list];

    } else {// oldlistが存在しない場合はoldlistを入れ替える
        oldlist = list;
    }
    // データ更新
    data = [NSKeyedArchiver archivedDataWithRootObject:oldlist];
    [pref setObject:data forKey:key];
    [pref synchronize];
    return true;
}

@end
