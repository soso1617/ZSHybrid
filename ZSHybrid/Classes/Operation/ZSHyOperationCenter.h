//
//  ZSHyOperationCenter.h
//  ParkPlatform
//
//  Created by SoSo. on 6/27/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZSHyOperation.h"
#import "ZSHyOperationDelegate.h"

/*********************************************************************
 *
 *  class ZSHyOperationCenter
 *
 *********************************************************************/

@interface ZSHyOperationCenter : NSObject

/**
 *  Singleton init
 *
 *  @return ZSHyOperationCenter instance
 */
+ (instancetype)defaultCenter;

/**
 *  Regiter the schemes which operation center could response, please use lower-case format.
 *  The application should only register once.
 *
 *  @param schemes An array of schemes;
 */
- (void)registerHybridScheme:(NSArray<NSString *> *)schemes;

/**
 *  Register url based operation from hybrid manager
 *
 *  @param operationsNames  the exact operations names in array
 *  @param manager          the hybrid scenario manager to handle the operation
 */

/**
 *  Register url based operation from the handler
 *
 *  @param operationsNames the exact operations names in array
 *  @param handler         the handler to handle the operations
 */
- (void)registerOperation:(NSArray<NSString *> *)operationsNames fromHandler:(id<ZSHyOperationDelegate>)handler;

/**
 *  Determine whether any registered hybrid manager need to handle the url request
 *  WebViewController will be responsible for invoke this method
 *
 *  @param webView webview
 *  @param request urlRequet
 *
 *  @return Y or N of handling
 */
- (BOOL)shouldHandleUrlRequest:(NSURLRequest *)request forWebView:(UIWebView *)webView;

/**
 *  Callback to webview with parameter for current operation
 *
 *  @param webView      webview
 *  @param operation    operation object
 *  @param parameters   parameter (JSON string is preferred)
 *  @param bSuccess     callback successful or failed
 *
 *  @return Y or N if callback is acceptable
 */
- (BOOL)callback2WebView:(UIWebView *)webView
            forOperation:(ZSHyOperation *)operation
        withParametersString:(NSString *)parameters
                 successFlag:(BOOL)bSuccess;

@end
