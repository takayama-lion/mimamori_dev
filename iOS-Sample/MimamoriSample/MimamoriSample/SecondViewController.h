//
//  SecondViewController.h
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/21.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *BeaconMessageLabel;
@property (nonatomic, strong) IBOutlet UISwitch *BeaconSwitch;
@property (nonatomic, strong) IBOutlet UIButton *ExplanationBtn;

/**
 * on Beacon switch
 */
- (IBAction)onBeaconSwitch:(id)sender;

- (IBAction)returnExplanation:(UIStoryboardSegue *)unwindSegue;
- (IBAction)returnRegistration:(UIStoryboardSegue *)unwindSegue;


@end

