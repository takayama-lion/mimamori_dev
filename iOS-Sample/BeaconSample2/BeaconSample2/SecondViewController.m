//
//  SecondViewController.m
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "SecondViewController.h"
#import "Constants.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogDisplay:(id)sender
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *msg = [pref stringForKey:LOG];
    [self.LogLabel setText:msg];
    [self.LogLabel sizeToFit];
    
    self.ScrollView.contentSize = CGSizeMake(self.LogLabel.frame.size.width, self.LogLabel.frame.size.height);
}
- (IBAction)onLogResetButton:(id)sender
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref removeObjectForKey:LOG];
    [pref synchronize];
    [self.LogLabel setText:@""];
}
@end
