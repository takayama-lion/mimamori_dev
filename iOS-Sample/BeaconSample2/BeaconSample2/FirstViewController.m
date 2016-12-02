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
    // Do any additional setup after loading the view, typically from a nib.
    _Beacon[0] = [[MimamoriBeacon alloc] initIdentifier:@"BeaconSample2_1"];
    _Beacon[0].delegate = self;
    _Beacon[1] = [[MimamoriBeacon alloc] initIdentifier:@"BeaconSample2_2"];
    _Beacon[1].delegate = self;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *uuid1 = [pref stringForKey:UUID1];
    NSString *major1 = [pref stringForKey:MAJOR1];
    NSString *minor1 = [pref stringForKey:MINOR1];
    NSString *uuid2 = [pref stringForKey:UUID2];
    NSString *major2 = [pref stringForKey:MAJOR2];
    NSString *minor2 = [pref stringForKey:MINOR2];
    if ([uuid1 length]) {
        [self.UUIDField1 setText:uuid1];
        if ([major1 length]) {
            [self.MajorField1 setText:major1];
            if ([minor1 length]) {
                [self.MinorField1 setText:minor1];
            }
        }
    }
    if ([uuid2 length]) {
        [self.UUIDField2 setText:uuid2];
        if ([major2 length]) {
            [self.MajorField2 setText:major2];
            if ([minor2 length]) {
                [self.MinorField2 setText:minor2];
            }
        }
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
    NSString *minor1 = nil;
    NSString *uuid2 = nil;
    NSString *major2 = nil;
    NSString *minor2 = nil;
    if (self.UUIDField1 != nil && [self.UUIDField1.text length]) {
        uuid1 = self.UUIDField1.text;
    }
    if (self.MajorField1 != nil && [self.MajorField1.text length]) {
        major1 = self.MajorField1.text;
    }
    if (self.MinorField1 != nil && [self.MinorField1.text length]) {
        minor1 = self.MinorField1.text;
    }
    if (self.UUIDField2 != nil && [self.UUIDField2.text length]) {
        uuid2 = self.UUIDField2.text;
    }
    if (self.MajorField2 != nil && [self.MajorField2.text length]) {
        major2 = self.MajorField2.text;
    }
    if (self.MinorField2 != nil && [self.MinorField2.text length]) {
        minor2 = self.MinorField2.text;
    }
    // 値設定
    if ([self setBeaconNumber:0 UUID:uuid1 major:major1 minor:minor1]) {
        [_Beacon[0] on];
    }
    if ([self setBeaconNumber:1 UUID:uuid2 major:major2 minor:minor2]) {
        [_Beacon[1] on];
    }

    [self.BeaconOnBtn setAlpha:0.5f];
    [self.BeaconOffBtn setAlpha:1.0f];
    [self.view endEditing:YES];

}
- (IBAction)setBtnBeaconOff:(id)sender
{
    NSLog(@"beacon OFF");
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *uuid1 = [pref stringForKey:UUID1];
    NSString *major1 = [pref stringForKey:MAJOR1];
    NSString *minor1 = [pref stringForKey:MINOR1];
    NSString *uuid2 = [pref stringForKey:UUID2];
    NSString *major2 = [pref stringForKey:MAJOR2];
    NSString *minor2 = [pref stringForKey:MINOR2];

    // 値設定
    if ([self setBeaconNumber:0 UUID:uuid1 major:major1 minor:minor1]) {
        [_Beacon[0] off];
    }
    if ([self setBeaconNumber:1 UUID:uuid2 major:major2 minor:minor2]) {
        [_Beacon[1] off];
    }
    [self.BeaconOnBtn setAlpha:1.0f];
    [self.BeaconOffBtn setAlpha:0.5f];
}
/**
 * set beacon
 */
- (BOOL)setBeaconNumber:(int)num UUID:(NSString *)uuid major:(NSString *)major minor:(NSString *)minor
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *UUID;
    NSString *MAJOR;
    NSString *MINOR;
    if (num == 1) {
        UUID = UUID2;
        MAJOR = MAJOR2;
        MINOR = MINOR2;
    } else {
        UUID = UUID1;
        MAJOR = MAJOR1;
        MINOR = MINOR1;
    }
    if ([uuid length]) {
        if ([major length]) {
            if ([minor length]) {
                [pref setValue:uuid forKey:UUID];
                [pref setValue:major forKey:MAJOR];
                [pref setValue:minor forKey:MINOR];
                [_Beacon[num] setUUID:uuid major:major minor:minor];
                
            } else {
                [pref setValue:uuid forKey:UUID];
                [pref setValue:major forKey:MAJOR];
                [pref removeObjectForKey:MINOR];
                [_Beacon[num] setUUID:uuid major:major];
                
            }
        } else {
            [pref setValue:uuid forKey:UUID];
            [pref removeObjectForKey:MAJOR];
            [pref removeObjectForKey:MINOR];
            [_Beacon[num] setUUID:uuid];
            
        }
        [pref synchronize];
        return YES;
    } else {
        [pref removeObjectForKey:UUID];
        [pref removeObjectForKey:MAJOR];
        [pref removeObjectForKey:MINOR];
        [pref synchronize];
        return NO;
    }

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
/**
 * is beacon
 */
- (void)isBeacon:(BOOL)status
{
    
}
- (void)limitOff:(NSTimer *)timer
{
    NSLog(@"limit off");
    _isSendMsg = NO;
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
                                                    message:@"BlueToothがONになっています。みまもり参加するにはONにしてください。"
                                                   delegate:self
                                          cancelButtonTitle:@"変更しない"
                                          otherButtonTitles:@"変更する", nil];
    [alert show];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"----[%ld]", (long)buttonIndex);
}
@end
