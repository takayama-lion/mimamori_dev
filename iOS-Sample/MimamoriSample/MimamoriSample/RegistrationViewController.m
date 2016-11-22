//
//  RegistrationViewController.m
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/22.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "RegistrationViewController.h"
#import "MimamoriMemberConstants.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"returnRegistration"]) {
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setBool:YES forKey:BEACON_STATUS];
        [pref synchronize];
    }
    return YES;
}
@end
