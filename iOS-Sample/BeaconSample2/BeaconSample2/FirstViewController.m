//
//  FirstViewController.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.Beacon = [[MimamoriBeacon alloc] init];
    self.Beacon.delegate = self;
//    [self.Beacon setUUID:@"53544152-4a50-4e40-8154-2631935eb10b" major:@"1"];
    Preference *pref = [[Preference alloc] init];
    NSString *uuid = [pref getStringForKey:@"UUID"];
    if (uuid != nil) {
        [self.UUIDField setText:[pref getStringForKey:@"UUID"]];
        [self.MajorField setText:[pref getStringForKey:@"Major"]];
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
    if (self.UUIDField.text != nil) {
        if (self.MajorField != nil) {
            [self.Beacon setUUID:self.UUIDField.text major:self.MajorField.text];
            Preference *pref = [[Preference alloc] init];
            [pref setString:self.UUIDField.text forKey:@"UUID"];
            [pref setString:self.MajorField.text forKey:@"Major"];
            [pref synchronize];
        } else {
            [self.Beacon setUUID:self.UUIDField.text];
            [Preference setString:self.UUIDField.text forKey:@"UUID"];
        }
    }
    [self.Beacon on];
    [self.BeaconOnBtn setAlpha:0.5f];
    [self.BeaconOffBtn setAlpha:1.0f];

}
- (IBAction)setBtnBeaconOff:(id)sender
{
    NSLog(@"beacon OFF");
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
    [self.LogLabel setText:log];
}
@end
