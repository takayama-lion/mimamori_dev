//
//  FirstViewController.h
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/21.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *StatusBtn;

- (IBAction)statusBtn:(id)sender;

- (IBAction)returnExplanation2:(UIStoryboardSegue *)unwindSegue;
@end

