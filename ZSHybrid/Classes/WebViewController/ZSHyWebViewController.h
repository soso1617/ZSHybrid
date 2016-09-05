//
//  ZSHyWebViewController.h
//  ParkPlatform
//
//  Created by SoSo. on 7/15/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <UIKit/UIKit.h>

/*********************************************************************
 *
 *  class ZSHyWebViewController
 *
 *********************************************************************/

@class ZSHyOperation;

@interface ZSHyWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong, readonly) UIWebView *webView;     // webview, use WKWebView in the future if it could post httpbody :)

/**
 *  Load url request
 *
 *  @param urlRequest url request
 */
- (void)loadURLRequest:(NSURLRequest *)urlRequest;

/**
 *  Load url string
 *
 *  @param urlString a url string
 */
- (void)loadURLString:(NSString *)urlString;

/**
 *  Inject JavaScript script in webview
 *
 *  @param JSString script string
 *
 *  @return the script result string
 */
- (NSString *)evaluateJSString:(NSString *)JSString;

/**
 *  Callback to webview from operation callback name
 *
 *  @param operation operation
 *  @param message   callback to web message/parameter (could use JSON string)
 #  @param bSuccess  callback for success or fail
 */
- (void)invokeCallbackToWeb:(ZSHyOperation *)operation
          withMessageString:(NSString *)message
                successFlag:(BOOL)bSuccess;
@end
