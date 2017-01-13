//
//  FirstViewController.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "FirstViewController.h"
#import "LocalNotification.h"
#import "Constants.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _IBeacon = [[MimamoriIBeacon alloc] initWithMenuId:@"1230"];
    _IBeacon.delegate = self;
    if ([_IBeacon isRunning]) {
        NSLog(@"------beacon running");
    }
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *uuid1 = [pref stringForKey:UUID1];
    NSString *major1 = [pref stringForKey:MAJOR1];
    NSString *major2 = [pref stringForKey:MAJOR2];
    NSString *major3 = [pref stringForKey:MAJOR3];
    NSString *major4 = [pref stringForKey:MAJOR4];

    if (![uuid1 length]) {
        uuid1 = @"d4c3ccc0-29fb-11e5-884f-0002a5d5c51b";
    }
    
    if ([uuid1 length]) {
        [self.UUIDField1 setText:uuid1];
    }

    if ([major1 length]) {
        [self.MajorField1 setText:major1];
    }
    if ([major2 length]) {
        [self.MajorField2 setText:major2];
    }
    if ([major3 length]) {
        [self.MajorField3 setText:major3];
    }
    if ([major4 length]) {
        [self.MajorField4 setText:major4];
    }
    
    [self.BeaconOnBtn setAlpha:1.0f];
    [self.BeaconOffBtn setAlpha:0.5f];
    
    // 背景をキリックしたら、キーボードを隠す
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
}
// キーボードを隠す処理
- (void)closeSoftKeyboard {
    [self.view endEditing: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    self.PeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil];

}
- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
}
- (IBAction)setBtnBeaconOn:(id)sender
{
    NSLog(@"beacon ON");
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:LOG];

    _isSendMsg = NO;
    NSString *uuid1 = nil;
    NSString *major1 = nil;
    NSString *major2 = nil;
    NSString *major3 = nil;
    NSString *major4 = nil;
    NSMutableArray *areaList = [NSMutableArray array];
    if (self.UUIDField1 != nil && [self.UUIDField1.text length]) {
        uuid1 = self.UUIDField1.text;
    }
    if (self.MajorField1 != nil && [self.MajorField1.text length]) {
        major1 = self.MajorField1.text;
        [areaList addObject:major1];
    }
    if (self.MajorField2 != nil && [self.MajorField2.text length]) {
        major2 = self.MajorField2.text;
        [areaList addObject:major2];
    }
    if (self.MajorField3 != nil && [self.MajorField3.text length]) {
        major3 = self.MajorField3.text;
        [areaList addObject:major3];
    }
    if (self.MajorField4 != nil && [self.MajorField4.text length]) {
        major4 = self.MajorField4.text;
        [areaList addObject:major4];
    }
    [pref setObject:uuid1 forKey:UUID1];
    [pref setObject:major1 forKey:MAJOR1];
    [pref setObject:major2 forKey:MAJOR2];
    [pref setObject:major3 forKey:MAJOR3];
    [pref setObject:major4 forKey:MAJOR4];
    [pref synchronize];
    
    _IBeacon.UUID = uuid1;
    [_IBeacon setAreaLists:areaList];
    [_IBeacon on];


    [self.BeaconOnBtn setAlpha:0.5f];
    [self.BeaconOffBtn setAlpha:1.0f];
    [self.view endEditing:YES];

}
- (IBAction)setBtnBeaconOff:(id)sender
{
    NSLog(@"beacon OFF");
    [_IBeacon off];

    [self.BeaconOnBtn setAlpha:1.0f];
    [self.BeaconOffBtn setAlpha:0.5f];
}
/**
 * serach beacon
 */
- (void)searchBeaconInfo:(NSString *)message title:(NSString *)title
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *msg = [pref stringForKey:LOG];
    NSString *msg2 = nil;
    if ([msg length]) {
        if ([msg length] > 10000) {
            NSLog(@"--log clean");
            msg = @"";
        }
        msg2 = [NSString stringWithFormat:@"%@\n%@\n", msg, message];
    } else {
        msg2 = [NSString stringWithFormat:@"%@\n", message];
    }
    [pref setValue:msg2 forKey:LOG];
    [pref synchronize];
    
    // 画面通知
    [LocalNotification sendLocalMessage:message];
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertController animated:YES completion:^{
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8
                             animations:^{
                                 alertController.view.alpha  = 0.0;
                             } completion:^(BOOL finished){
                                 [alertController dismissViewControllerAnimated:NO completion:nil];
                             }];
        });
    }];

    
    NSLog(@"beacon:%@", message);
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            NSLog(@"初期値");
            break;
        case CBPeripheralManagerStateResetting:
            NSLog(@"システムとの接続が一時的に切れた");
            break;
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"BLE のサーバに機能がない");
            break;
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"BLE のサーバになる権限がない");
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"BLE が OFF になっている");
            break;
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"BLE が ON になっている");
            break;
        default:
            break;
    }
}
- (void)showAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BlueTooth"
                                                    message:@"BlueToothがOFFになっています。みまもり参加するにはONにしてください。"
                                                   delegate:self
                                          cancelButtonTitle:@"変更しない"
                                          otherButtonTitles:@"変更する", nil];
    [alert show];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"----[%ld]", (long)buttonIndex);
}
/**
 * get output beacons
 * param (NSArray *)beaconInfo
 */
- (void)getOutputBeacons:(NSArray *)beaconInfo
{
    NSString *message = @"";
    for (IBeaconInfo *info in beaconInfo) {
        message = [NSString stringWithFormat:@"%@\nUUID=[%@] Major=[%@] Minor=[%@] Latitude=[%f] Longitude=[%f] status=[%@]", message, info.UUID, info.Major, info.Minor, info.Latitude, info.Longitude, info.Status];
    }
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *msg = [pref stringForKey:LOG];
    if ([msg length]) {
        if ([msg length] > 10000) {
            NSLog(@"--log clean");
            msg = @"";
        }
        msg = [NSString stringWithFormat:@"%@\n%@\n", msg, message];
    } else {
        msg = [NSString stringWithFormat:@"%@\n", message];
    }
    [pref setValue:msg forKey:LOG];
    [pref synchronize];
    
    // 画面通知
    [LocalNotification sendLocalMessage:message];
    
    // インスタンス生成
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 5分後に通知をする（設定は秒単位）
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(1)];
    // タイムゾーンの設定
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 通知時に表示させるメッセージ内容
    notification.alertBody = message;
    // 通知に鳴る音の設定
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知の登録
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"beacon info" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alertController animated:YES completion:^{
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.8
                             animations:^{
                                 alertController.view.alpha  = 0.0;
                             } completion:^(BOOL finished){
                                 [alertController dismissViewControllerAnimated:NO completion:nil];
                             }];
        });
    }];
    
    
    NSLog(@"beacon:%@", message);

}
@end
