//
//  FirstViewController.h
//  BeaconSample2
//
//  Created by 高山博行 on 2016/11/17.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MimamoriBeacon.h"

@interface FirstViewController : UIViewController<BeaconDelegate>

@property (strong, nonatomic) MimamoriBeacon *Beacon;
@property (strong, nonatomic) IBOutlet UITextField *UUIDField;
@property (strong, nonatomic) IBOutlet UITextField *MajorField;
@property (strong, nonatomic) IBOutlet UIButton *BeaconOnBtn;
@property (strong, nonatomic) IBOutlet UIButton *BeaconOffBtn;
@property (strong, nonatomic) IBOutlet UILabel *LogLabel;
@property (strong, nonatomic) IBOutlet UIButton *LogResetBtn;

- (IBAction)setBtnBeaconOn:(id)sender;
- (IBAction)setBtnBeaconOff:(id)sender;
- (IBAction)setLogReset:(id)sender;

@end

