//
//  ViewController.m
//  WebViewSample
//
//  Created by 高山博行 on 2016/11/30.
//  Copyright © 2016年 高山博行. All rights reserved.
//

#import "ViewController.h"
#import "HttpClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.WebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.WebViewBase.frame.size.width, self.WebViewBase.frame.size.height)];
    
    self.WebView.translatesAutoresizingMaskIntoConstraints = NO;

    // デリゲートにこのビューコントローラを設定する
    self.WebView.navigationDelegate = self;
    
    // フリップでの戻る・進むを有効にする
    self.WebView.allowsBackForwardNavigationGestures = NO;
    
    // WKWebView インスタンスを画面に配置する
    [self.WebViewBase addSubview:self.WebView];
    
    NSURL *url = [NSURL URLWithString:@"https://www.syon.co.jp/"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.WebView loadRequest:request];
    
    // 一旦 htmlの中身を取得しbodyタグの前にjavascriptのfunctionを追加して表示する
    [HttpClient requestData:@"https://www.syon.co.jp/" Response:^(NSData *data){
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self.WebView loadHTMLString:[str stringByReplacingOccurrencesOfString:@"</body>"
                                                                    withString:
                                      @"<script src=\"//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js\"></script>"
                                      "<script>"
                                      "function func(){"
                                      "return $('title').html();"
                                      "}"
                                      "</script></body>"]
                             baseURL:url];
        
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getValueButton:(id)sender
{
    NSString *str = @"func();";
    [self.WebView evaluateJavaScript:str completionHandler:^(id _Nullable html, NSError *_Nullable error) {
        NSString *str = (NSString *)html;
        self.ValueLabel.text = str;
        NSLog(@"---%@ %@", str, error);
    }];
    
}
/**
 * 読み込み開始時に実行されるUIWebViewのdelegateメソッド
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
}
/**
 * 読み込み完了時に実行されるUIWebViewのdelegateメソッド
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
}
/**
 * 読み込み時においてエラーが発生した場合のメソッド
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error=%@", error);
}
@end
