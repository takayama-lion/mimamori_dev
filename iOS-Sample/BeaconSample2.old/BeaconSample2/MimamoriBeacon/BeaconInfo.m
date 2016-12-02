//
//  BeaconInfo.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "BeaconInfo.h"

@implementation BeaconInfo

/**
 * init
 */
- (id)init
{
    if (self = [super init]) {
        self.Latitude = 0;
        self.Longitude = 0;
    }
    return self;
}
/**
 * is search
 * 全ての値が取得できているならYES
 * まらならNO
 */
- (BOOL)isSearch
{
    if (self.UUID != nil && self.Major != nil && self.Minor != nil && self.Latitude > 0 && self.Longitude > 0) {
        return YES;
    }
    return NO;
}
@end
