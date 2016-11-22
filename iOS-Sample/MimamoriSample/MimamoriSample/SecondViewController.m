//
//  SecondViewController.m
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/21.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "SecondViewController.h"
#import "MimamoriMemberConstants.h"
#import "ExplanationViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    int status = [pref integerForKey:CONTRIBUTION_STATUS];
    if (status == STATUS_NONE) {
        // 画面遷移
        ExplanationViewController *sampleView = [self.storyboard instantiateViewControllerWithIdentifier:@"Explanation"];
        sampleView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:sampleView animated:YES completion:nil];
    }
/*    switch (status) {
        case STATUS_UNREGIST: // 未登録
            buttonTitle = @"みまもり開始";
            break;
        case STATUS_REGIST: // 参加
            buttonTitle = @"みまもり終了";
            break;
        case STATUS_SEARCH: // 捜査中
            buttonTitle = @"みまもり終了";
            break;
        case STATUS_CLOSE: // 捜査終了
            buttonTitle = @"みまもり終了";
            break;
        case STATUS_PAUSE: // 休止
            buttonTitle = @"みまもり開始";
            break;
        case STATUS_NONE: // null - 協力願い
        default:
    }*/
    BOOL beaconStatus = [pref boolForKey:BEACON_STATUS];
    self.BeaconSwitch.on = beaconStatus;
    if (beaconStatus) {
        self.BeaconMessageLabel.text = @"ON (協力中)";
    } else {
        self.BeaconMessageLabel.text = @"OFF (休止中)";
    }
    //[self.BeaconBtn setTitle:buttonTitle forState:UIControlStateNormal];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * on Beacon switch
 */
- (IBAction)onBeaconSwitch:(id)sender
{
    BOOL status = self.BeaconSwitch.on;
    if (status) {
        self.BeaconMessageLabel.text = @"ON (協力中)";
    } else {
        self.BeaconMessageLabel.text = @"OFF (休止中)";
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"" message:@"みまもり捜索への協力ありがとうございました。" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alertController animated:YES completion:^{
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.4
                                 animations:^{
                                     alertController.view.alpha  = 0.0;
                                 } completion:^(BOOL finished){
                                     [alertController dismissViewControllerAnimated:NO completion:nil];
                                 }];
            });
        }];
    }
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setBool:status forKey:BEACON_STATUS];
    [pref synchronize];
}
- (IBAction)returnExplanation:(UIStoryboardSegue *)unwindSegue
{
    // 中身は空っぽでよい。
}
- (IBAction)returnRegistration:(UIStoryboardSegue *)unwindSegue
{
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Explanation"]) {
        ExplanationViewController *controller = segue.destinationViewController;
        controller.Status = STATUS_REGIST;
    }
}
@end
