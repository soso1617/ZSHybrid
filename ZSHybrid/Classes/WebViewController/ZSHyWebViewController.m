//
//  ZSHyWebViewController.m
//  ParkPlatform
//
//  Created by SoSo. on 7/15/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import "ZSHyWebViewController.h"
#import "ZSHyOperationCenter.h"

/*********************************************************************
 *
 *  class ZSHyWebViewController
 *
 *********************************************************************/

@interface ZSHyWebViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) BOOL bShowIndicator;

@end

@implementation ZSHyWebViewController

@synthesize webView = _webView;

/**
 *  Init
 *
 *  @return Class instance
 */
- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _webView = [[WKWebView alloc] init];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.frame = self.view.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Method

/**
 *  Load url request
 *
 *  @param urlRequest a url request
 */
- (void)loadURLRequest:(NSURLRequest *)urlRequest
{
    [self.webView loadRequest:urlRequest];
}

/**
 *  Load url string
 *
 *  @param urlString a url string
 */
- (void)loadURLString:(NSString *)urlString
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

/**
 *  Evaluate JavaScript String in wkwebview
 *
 *  @param JSString Java Script string
 *  @param handler  evaluate result
 */
- (void)evaluateJSString:(NSString *)JSString withCompletionHandler:(void (^)(NSString *result))handler
{
    //
    //  delay 0.1 to end webview's alert runloop if exist
    //
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
       [self.webView evaluateJavaScript:JSString completionHandler:^(id _Nullable retValue, NSError * _Nullable error)
        {
            if (nil != handler)
            {
                handler(retValue);
            }
        }];
    });
}

#pragma mark - WKWebView delegate Method

/**
 *  WKWebView delegate method, each hybrid function could contains it's own url process logic, so each sub-class could override this method, but don't forget to invoke super method to ensure the standard process
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    BOOL bRet = ![[ZSHyOperationCenter defaultCenter] shouldHandleUrlRequest:navigationAction.request forWeb:self];
    
    decisionHandler(bRet ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action)
                                                            {
                                                                completionHandler();
                                                            }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
