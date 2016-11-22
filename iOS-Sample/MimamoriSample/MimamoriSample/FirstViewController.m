//
//  FirstViewController.m
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/21.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "FirstViewController.h"
#import "MimamoriMemberConstants.h"

extern NSString *const CONTRIBUTION_STATUS;

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)statusBtn:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ステータス設定" message:@"選択してください。" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 上から順にボタンが配置
    [alertController addAction:[UIAlertAction actionWithTitle:@"未登録" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setStatus:STATUS_NONE];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"登録済み" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setStatus:STATUS_REGIST];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)setStatus:(int)status
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setInteger:status forKey:CONTRIBUTION_STATUS];
    [pref synchronize];
}
- (IBAction)returnExplanation2:(UIStoryboardSegue *)unwindSegue
{
    
}
@end
