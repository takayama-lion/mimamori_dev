//
//  MimamoriMemberConstants.m
//  MimamoriSample
//
//  Created by 高山博行 on 2016/11/22.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "MimamoriMemberConstants.h"

// preference
// みまもりステータス
NSString *const CONTRIBUTION_STATUS = @"contribution_status";
// Beacon ステータス
NSString *const BEACON_STATUS = @"beacon_status";

// みまもりステータス
const int STATUS_NONE   = 0; // null
const int STATUS_UNREGIST = 1; // 未登録
const int STATUS_REGIST   = 2; // 登録
const int STATUS_SEARCH = 3; // 捜査中
const int STATUS_CLOSE  = 4; // 捜査終了
const int STATUS_PAUSE  = 9; // 休止
