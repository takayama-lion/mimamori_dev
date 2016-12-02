//
//  BeaconInfo.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconInfo : NSObject

/**
 * init
 */
- (id)init;

/**
 * is search
 * 全ての値が取得できているならYES
 * まらならNO
 */
- (BOOL)isSearch;

@property (strong, nonatomic) NSString *UUID;
@property (strong, nonatomic) NSString *Major;
@property (strong, nonatomic) NSString *Minor;
@property double *Latitude;
@property double *Longitude;

@end
