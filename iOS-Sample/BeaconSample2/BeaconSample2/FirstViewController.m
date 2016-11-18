//
//  FirstViewController.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "FirstViewController.h"
#import "LocalNotification.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.Beacon = [[MimamoriBeacon alloc] initIdentifier:@"BeaconSample2"];
    self.Beacon.delegate = self;
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [pref stringForKey:@"UUID"];
    NSString *major = [pref stringForKey:@"Major"];
    if ([uuid length]) {
        [self.UUIDField setText:uuid];
        if ([major length]) {
            [self.MajorField setText:major];
        }
    } else {
        [self.UUIDField setText:@"53544152-4a50-4e40-8154-2631935eb10b"];
    }
    [self.BeaconOnBtn setAlpha:1.0f];
    [self.BeaconOffBtn setAlpha:0.5f];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setBtnBeaconOn:(id)sender
{
    NSLog(@"beacon ON");
    NSString *uuid = nil;
    NSString *major = nil;
    if (self.UUIDField != nil && [self.UUIDField.text length]) {
        uuid = self.UUIDField.text;
    }
    if (self.MajorField != nil && [self.MajorField.text length]) {
        major = self.MajorField.text;
    }
    if (uuid != nil) {
        if (major != nil) {
            [self.Beacon setUUID:uuid major:major];
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setValue:uuid forKey:@"UUID"];
            [pref setValue:major forKey:@"Major"];
            [pref synchronize];
        } else {
            [self.Beacon setUUID:uuid];
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setValue:uuid forKey:@"UUID"];
            [pref removeObjectForKey:@"Major"];
            [pref synchronize];
        }
    }
    [self.Beacon on];
    [self.BeaconOnBtn setAlpha:0.5f];
    [self.BeaconOffBtn setAlpha:1.0f];
    [self.view endEditing:YES];

}
- (IBAction)setBtnBeaconOff:(id)sender
{
    NSLog(@"beacon OFF");
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [pref stringForKey:@"UUID"];
    NSString *major = [pref stringForKey:@"Major"];
    [self.Beacon setUUID:uuid major:major];
    [self.Beacon off];
    [self.BeaconOnBtn setAlpha:1.0f];
    [self.BeaconOffBtn setAlpha:0.5f];
}
- (IBAction)setLogReset:(id)sender
{
    NSLog(@"log rest");
    if (self.LogLabel != nil) {
        [self.LogLabel setText:@""];
    }
}
/**
 * serach beacon
 */
- (void)searchBeaconInfo:(BeaconInfo *)beaconInfo
{
    NSString *log = [NSString stringWithFormat:@"UUID=%@\n Major=%@\n Minor=%@\n Latitude=%f\n Longitude=%f", beaconInfo.UUID, beaconInfo.Major, beaconInfo.Minor, *beaconInfo.Latitude, *beaconInfo.Longitude];
    [LocalNotification sendLocalMessage:log];
    [self.LogLabel setText:log];
}
@end
