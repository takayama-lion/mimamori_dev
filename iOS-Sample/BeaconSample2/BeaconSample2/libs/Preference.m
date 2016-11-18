//
//  Preference.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "Preference.h"

@implementation Preference

/**
 * init
 */
- (id)init
{
    if (self = [super init]) {
        _pref = [NSUserDefaults standardUserDefaults];
    }
    return self;
}
/**
 * synchronize
 */
- (void)synchronize
{
    [_pref synchronize];
}
/**
 * set string value
 */
- (void)setString:(NSString *)value forKey:(NSString *)key
{
    [_pref setObject:value forKey:key];
}
/**
 * remove key
 */
- (void)removeForkey:(NSString *)key
{
    [_pref removeObjectForKey:key];
}
/**
 * get string value
 */
- (NSString *)getStringForKey:(NSString *)key
{
    return [_pref stringForKey:key];
}
//***** static
/**
 * set string value
 */
+ (void)setString:(NSString *)value forKey:(NSString *)key
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:value forKey:key];
    [pref synchronize];
}
/**
 * get string value
 */
+ (NSString *)getStringForKey:(NSString *)key
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    return [pref stringForKey:key];
}
/**
 * remove key
 */
+ (void)removeForkey:(NSString *)key
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:key];
    [pref synchronize];
}

@end
