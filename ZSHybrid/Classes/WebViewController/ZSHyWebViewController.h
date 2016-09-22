//
//  ZSHyWebViewController.h
//  ParkPlatform
//
//  Created by SoSo. on 7/15/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/*********************************************************************
 *
 *  class ZSHyWebViewController
 *
 *********************************************************************/

@class ZSHyOperation;

@interface ZSHyWebViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong, readonly) WKWebView *webView;     // webview, use WKWebView in the future if it could post httpbody :)

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
 *  Evaluate JavaScript String in wkwebview
 *
 *  @param JSString Java Script string
 *  @param handler  evaluate result
 */
- (void)evaluateJSString:(NSString *)JSString withCompletionHandler:(void (^)(NSString *result))handler;

@end
