//
//  ExplanationViewController.m
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/22.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "ExplanationViewController.h"

@interface ExplanationViewController ()

@end

@implementation ExplanationViewController

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
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.Status > 0) {
        self.JoinBtn.hidden = YES;
        self.ReturnBtn.hidden = YES;
        self.WarningView.hidden = YES;
        self.ReturnBtn2.hidden = NO;
    } else {
        self.JoinBtn.hidden = NO;
        self.ReturnBtn.hidden = NO;
        self.WarningView.hidden = NO;
        self.ReturnBtn2.hidden = YES;
    }
}

- (IBAction)ReturnBtn:(id)sender
{

}
@end
