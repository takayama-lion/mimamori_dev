//
//  ViewController.h
//  WebViewSample
//
//  Created by 高山博行 on 2016/11/30.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController<WKNavigationDelegate> // WKWebViewのdelegate設定

@property (nonatomic, strong) WKWebView *WebView; // WebView
@property (nonatomic, strong) IBOutlet UIView *WebViewBase; // WebViewをセットするView
@property (nonatomic, strong) IBOutlet UILabel *ValueLabel; // 取得値表示
@property (nonatomic, strong) IBOutlet UIButton *GetValueButton; // ボタン

- (IBAction)getValueButton:(id)sender;

@end

