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

@property (nonatomic, strong) UIWebView *webView;
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
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
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
 *  Inject JavaScript script in webview
 *
 *  @param JSString script string
 */

/**
 *  Inject JavaScript script in webview
 *
 *  @param JSString script string
 *
 *  @return the script result string
 */
- (NSString *)evaluateJSString:(NSString *)JSString
{
    return [self.webView stringByEvaluatingJavaScriptFromString:JSString];
}

/**
 *  Callback to webview from operation callback name
 *
 *  @param operation operation
 *  @param message   callback to web message/parameter (could use JSON string)
 #  @param bSuccess  callback for success or fail
 */
- (void)invokeCallbackToWeb:(ZSHyOperation *)operation withMessageString:(NSString *)message successFlag:(BOOL)bSuccess
{
    [[ZSHyOperationCenter defaultCenter] callback2WebView:self.webView forOperation:operation withParametersString:message successFlag:bSuccess];
}

#pragma mark - UIWebView delegate Method

/**
 *  UIWebView delegate method, each hybrid function could contains it's own url process logic, so each sub-class could override this method, but don't forget to invoke super method to ensure the standard process
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL bRet = ![[ZSHyOperationCenter defaultCenter] shouldHandleUrlRequest:request forWebView:webView];
    
    return bRet;
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
