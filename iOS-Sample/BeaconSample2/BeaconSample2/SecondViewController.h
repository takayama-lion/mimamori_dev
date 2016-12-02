//
//  SecondViewController.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView *ScrollView;
@property (nonatomic, strong) IBOutlet UILabel *LogLabel;
@property (nonatomic, strong) IBOutlet UIButton *LogResetButton;

- (IBAction)onLogDisplay:(id)sender;
- (IBAction)onLogResetButton:(id)sender;
@end

