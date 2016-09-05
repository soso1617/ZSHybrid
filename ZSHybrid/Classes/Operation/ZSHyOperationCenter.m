//
//  ZSHyOperationCenter.m
//  ParkPlatform
//
//  Created by SoSo. on 6/27/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import "ZSHyOperationCenter.h"
#import "ZSHyScenarioManager.h"

#define CALLID                      @"callID"
#define FETECHJSFORMAT              @"zshybrid.fetchParameter(\"%@\")"  // callID
#define CALLBACKJSFORMAT            @"zshybrid.callbackFromMobile(\"%@\", \"%@\", %@)"  // callID, parameters, successflag

@class ZSHyScenarioManager;

/*********************************************************************
 *
 *  class ZSHyOperationCenter
 *
 *********************************************************************/

@interface ZSHyOperationCenter ()

@property (nonatomic, strong) NSMutableDictionary *registeredOperationsManagersDictionary;
@property (nonatomic, strong) NSMutableArray<NSString *> *registeredSchemes;

@end

@implementation ZSHyOperationCenter

static ZSHyOperationCenter *_defaultCenter = nil;

#pragma mark - Public Method

/**
 *  Singleton init
 *
 *  @return ZSHyOperationCenter instance
 */
+ (instancetype)defaultCenter
{
    @synchronized(self)
    {
        if (nil == _defaultCenter)
        {
            _defaultCenter = [[ZSHyOperationCenter alloc] init];
        }
        
        return _defaultCenter;
    }
}

/**
 *  Init
 *
 *  @return self instance
 */
- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _registeredOperationsManagersDictionary = [NSMutableDictionary dictionary];
        _registeredSchemes = [NSMutableArray array];
    }
    
    return self;
}

/**
 *  Regiter the schemes which operation center could response, please use lower-case format.
 *  The application should only register once.
 *
 *  @param schemes An array of schemes;
 */
- (void)registerHybridScheme:(NSArray<NSString *> *)schemes
{
    [self.registeredSchemes addObjectsFromArray:schemes];
}

/**
 *  Register url based operation from the handler
 *
 *  @param operationsNames the exact operations names in array
 *  @param handler         the handler to handle the operations
 */
- (void)registerOperation:(NSArray<NSString *> *)operationsNames fromHandler:(id<ZSHyOperationDelegate>)handler
{
    if (nil != operationsNames && nil != handler)
    {
        for (NSString *name in operationsNames)
        {
            //
            //  Important:if same key was registered by another hanlder will override the hanlder
            //
            [self.registeredOperationsManagersDictionary setObject:handler forKey:name];
        }
    }
}

/**
 *  Determine whether any registered hybrid manager need to handle the url request
 *
 *  @param request urlRequet
 *
 *  @return Y or N of handling
 */
- (BOOL)shouldHandleUrlRequest:(NSURLRequest *)request forWebView:(UIWebView *)webView
{
    BOOL bRet = NO;
    
    ZSHyOperation *operation = [self operationFromURLRequest:request fromWebView:webView];
    
    switch (operation.operationMode)
    {
        case OM_PROCESS:
        {
            //
            // do the operation
            //
            if ([operation.operationHandler conformsToProtocol:@protocol(ZSHyOperationDelegate)])
            {
                [operation.operationHandler handleOperation:operation];
            }
            
            bRet = YES;
            break;
        }
        case OM_REDIRECT:
        default:
        {
            bRet = NO;
            break;
        }
    }
    
    return bRet;
}

/**
 *  Create ZSHyOperation object from URL request
 *
 *  @param request the redirect url request
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromURLRequest:(NSURLRequest *)request fromWebView:(UIWebView *)webView
{
    ZSHyOperation *retOperation = nil;
    
    if ([request.HTTPMethod isEqualToString:@"GET"])
    {
        retOperation = [self operationFromGetURLRequest:request fromWebView:webView];
    }
    else if ([request.HTTPMethod isEqualToString:@"POST"])
    {
        retOperation = [self operationFromPostURLRequest:request];
    }
    
    return retOperation;
}

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
             successFlag:(BOOL)bSuccess
{
    BOOL bRet = NO;
    
    if (nil != operation.operationCallID)
    {
        //
        //  inject js for callback
        //
        NSString *injectJS4Callback = [NSString stringWithFormat:CALLBACKJSFORMAT, operation.operationCallID, parameters, [NSNumber numberWithBool:bSuccess]];
        
        //
        //  delay 0.1 to end webview's alert runloop if exist
        //
        [webView performSelector:@selector(stringByEvaluatingJavaScriptFromString:) withObject:injectJS4Callback afterDelay:0.1];
    }
    
    return bRet;
}

#pragma mark - Private Method

/**
 *  Create ZSHyOperation object from Post URL request
 *
 *  @param request the redirect url request
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromPostURLRequest:(NSURLRequest *)request
{
    ZSHyOperation *retOperation = [[ZSHyOperation alloc] init];
    retOperation.operationRequest = request;
    
    if ([self.registeredSchemes containsObject:request.URL.scheme])
    {
        NSString *host = request.URL.host;
        
        //
        //  mostly we should define host name as operation name
        //  eg: ZSHy://login/xxxx
        //
        if (self.registeredOperationsManagersDictionary[host])
        {
            retOperation.operationName = host;
            retOperation.operationMode = OM_PROCESS;
            retOperation.operationParameters = [self parseHttpPostData:request.HTTPBody];
            retOperation.operationHandler = self.registeredOperationsManagersDictionary[host];
        }
        //
        //  if host name not hit, we need to check the whole url
        //
        else
        {
            NSArray *allKeys = self.registeredOperationsManagersDictionary.allKeys;
            
            for (NSString *key in allKeys)
            {
                if ([request.URL.absoluteString containsString:key])
                {
                    retOperation.operationName = key;
                    retOperation.operationMode = OM_PROCESS;
                    retOperation.operationParameters = [self parseHttpPostData:request.HTTPBody];
                    retOperation.operationHandler = self.registeredOperationsManagersDictionary[key];
                    
                    break;
                }
            }
        }
    }
    
    return retOperation;
}

/**
 *  Create ZSHyOperation object from URL request, will use JavaScript to fetch parameters
 *
 *  @param request the redirect url request
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromGetURLRequest:(NSURLRequest *)request fromWebView:(UIWebView *)webView
{
    ZSHyOperation *retOperation = [[ZSHyOperation alloc] init];
    retOperation.operationRequest = request;
    
    if ([self.registeredSchemes containsObject:request.URL.scheme])
    {
        NSString *host = request.URL.host;
        
        //
        //  mostly we should define host name as operation name
        //  eg: ZSHy://login/xxxx
        //
        if (self.registeredOperationsManagersDictionary[host])
        {
            retOperation.operationName = host;
            retOperation.operationMode = OM_PROCESS;
            retOperation.operationHandler = self.registeredOperationsManagersDictionary[host];
            
            //
            //  get parameter and callback name
            //
            [self fetchParameterThroughJavaScript:request.URL.query fromWebView:webView forOperation:&retOperation];
        }
        //
        //  if host name not hit, we need to check the whole url
        //
        else
        {
            NSArray *allKeys = self.registeredOperationsManagersDictionary.allKeys;
            
            for (NSString *key in allKeys)
            {
                if ([request.URL.absoluteString containsString:key])
                {
                    retOperation.operationName = key;
                    retOperation.operationMode = OM_PROCESS;
                    retOperation.operationParameters = nil;
                    retOperation.operationHandler = self.registeredOperationsManagersDictionary[key];
                    
                    break;
                }
            }
        }
    }
    
    return retOperation;
}

/**
 *  Parse url query, and fetch parameter through JavaScript
 *
 *  @param urlQuery  url query
 *  @param webView   web view
 *  @param operation output operation
 */
- (void)fetchParameterThroughJavaScript:(NSString *)urlQuery
                            fromWebView:(UIWebView *)webView
                           forOperation:(ZSHyOperation **)operation
{
    if (nil != urlQuery)
    {
        NSDictionary *queryDictionary = [self parseDataString2Dictionary:urlQuery];
        
        NSString *callID = queryDictionary[CALLID];
        
        if (nil != callID)
        {
            (*operation).operationCallID = callID;
            
            //
            //  inject js for fetch parameter
            //
            NSString *injectJS4Parameter = [NSString stringWithFormat:FETECHJSFORMAT, callID];
            
            //
            //  JSON string or just like form submit?
            //
            NSString *parameterString = [webView stringByEvaluatingJavaScriptFromString:injectJS4Parameter];
            
            (*operation).operationParameters = [self parseDataString2Dictionary:parameterString];
        }
    }
}

/**
 *  Parse the data from server side
 *
 *  @param data data which present string like response_text=X2lucHV0X2NoYXJzZXQ9InV0Zi04IiZib2R5PSLkuIrmtbfov6rlo6vl...
 *  &confirmation_url=https%3A%2F%2Fwww.xxx
 *
 *  @return dictionary
 */
- (NSDictionary *)parseHttpPostData:(NSData *)data
{
    NSDictionary *retDictionary = nil;
    
    if (nil != data)
    {
        retDictionary = [self parseDataString2Dictionary:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    }
    
    return retDictionary;
}

/**
 *  Parsing UTF8 data string to dictionary
 *
 *  @param dataString UTF8 data string, the string should look like 
 *  response_text=X2lucHV0X2NoYXJzZXQ9InV0Zi04IiZib2R5PSLkuIrmtbfov6rlo6vl...&confirmation_url=https%3A%2F%2Fwww.xxx
 *
 *  @return dictionary
 */
- (NSDictionary *)parseDataString2Dictionary:(NSString *)dataString
{
    NSMutableDictionary *retDictionary = nil;
    
    if (nil != dataString)
    {
        retDictionary = [NSMutableDictionary dictionary];
        
        //
        //  start parsing
        //
        NSArray *separateArray = [dataString componentsSeparatedByString:@"&"];
        
        for (NSString *separateString in separateArray)
        {
            NSArray<NSString *> *separateArray = [separateString componentsSeparatedByString:@"="];
            
            //
            //  first one is key, second is value
            //
            if (2 == separateArray.count)
            {
                //
                //  should replace percent encoding
                //
                NSString *value = [separateArray[1] stringByRemovingPercentEncoding];
                
                [retDictionary setObject:value forKey:separateArray[0]];
            }
        }
    }
    
    return retDictionary;
}

@end
