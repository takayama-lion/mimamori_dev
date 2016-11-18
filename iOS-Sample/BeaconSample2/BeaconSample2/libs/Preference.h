//
//  Preference.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preference : NSObject {
    NSUserDefaults *_pref;
}

/**
 * init
 */
- (id)init;
/**
 * synchronize
 */
- (void)synchronize;
/**
 * set string value
 */
- (void)setString:(NSString *)value forKey:(NSString *)key;
/**
 * get string value
 */
- (NSString *)getStringForKey:(NSString *)key;
/**
 * remove key
 */
- (void)removeForkey:(NSString *)key;
//***** static
/**
 * set string value
 */
+ (void)setString:(NSString *)value forKey:(NSString *)key;
/**
 * get string value
 */
+ (NSString *)getStringForKey:(NSString *)key;
/**
 * remove key
 */
+ (void)removeForkey:(NSString *)key;
@end
