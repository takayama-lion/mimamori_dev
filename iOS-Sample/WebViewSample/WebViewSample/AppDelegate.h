//
//  AppDelegate.h
//  WebViewSample
//
//  Created by 高山博行 on 2016/11/30.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

