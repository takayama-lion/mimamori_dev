//
//  ExplanationViewController.h
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/22.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExplanationViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *JoinBtn;
@property (nonatomic, strong) IBOutlet UIButton *ReturnBtn;
@property (nonatomic, strong) IBOutlet UIView *WarningView;
@property (nonatomic, strong) IBOutlet UIButton *ReturnBtn2;
@property (nonatomic) NSUInteger Status;

- (IBAction)ReturnBtn:(id)sender;
@end
