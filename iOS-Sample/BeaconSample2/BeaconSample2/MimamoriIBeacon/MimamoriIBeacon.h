//
//  MimamoriIBeacon.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/12/19.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IBeaconInfo.h"

/**
 *  MimamoriIBeaconDelegate プロトコル
 */
@protocol MimamoriIBeaconDelegate <NSObject>

/**
 * get output beacons
 * param (NSArray *)beaconInfo
 */
- (void)getOutputBeacons:(NSArray *)beaconInfo;

@end

@interface MimamoriIBeacon : NSObject<CLLocationManagerDelegate> {
    NSMutableArray *_areaList;
    NSMutableDictionary *_regionList;
    NSTimer *_timer;
    BOOL _isTimer;
}

@property (nonatomic, assign) id<MimamoriIBeaconDelegate> delegate;

@property (strong, nonatomic) CLLocationManager *LocationManager;
@property (strong, nonatomic) CLBeaconRegion *Region;
@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSString *MenuId;
@property (nonatomic) float TimeOut;


/**
 * init
 * param (NSString *)menuId'
 */
- (id)initWithMenuId:(NSString *)menuId;
/**
 * init
 * param (NSString *)menuId'
 * param (NSString *)uuid
 */
- (id)initWithMenuId:(NSString *)menuId uuid:(NSString *)uuid;
/**
 * set area id
 * param:(NSMutableArray *)areaLists
 */
- (void)setAreaLists:(NSMutableArray *)areaLists;
/**
 * is running
 * return:(BOOL)
 */
- (BOOL)isRunning;
/**
 * is timeout
 * return:(BOOL)
 */
- (BOOL)isTimeOut;
/**
 * on
 */
- (void)on;
/**
 * off
 */
- (void)off;
@end
