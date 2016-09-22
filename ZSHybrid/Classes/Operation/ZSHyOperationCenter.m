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
- (void)registerOperation:(NSArray<NSString *> *)operationsNames
              fromHandler:(id<ZSHyOperationDelegate>)handler
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
 *  WebViewController will be responsible for invoke this method
 *
 *  @param webViewController        webviewController
 *  @param request                  urlRequet
 *
 *  @return Y or N of handling
 */
- (BOOL)shouldHandleUrlRequest:(NSURLRequest *)request forWeb:(ZSHyWebViewController *)webViewController
{
    BOOL bRet = NO;
    
    __block ZSHyOperation *operation = [self operationFromURLRequest:request fromWeb:webViewController withCompleteHandler:^
    {
        __strong ZSHyOperation *strongOperation = operation;
        
        //
        // do the operation after parameter get
        //
        if ([strongOperation.operationHandler conformsToProtocol:@protocol(ZSHyOperationDelegate)])
        {
            [strongOperation.operationHandler handleOperation:strongOperation];
        }
    }];
    
    //
    //  return result before handler operates
    //
    switch (operation.operationMode)
    {
        case OM_PROCESS:
        {
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
 *  Callback to webview with parameter for current operation
 *
 *  @param ZSHyWebViewController    webviewController
 *  @param operation                operation object
 *  @param parameters               parameter (JSON string is preferred)
 *  @param bSuccess                 call successful or failed function in JS
 *
 *  @return Y or N if callback is acceptable
 */
- (BOOL)callback2Web:(ZSHyWebViewController *)webViewController
       withOperation:(ZSHyOperation *)operation
    parametersString:(NSString *)parameters
         successFlag:(BOOL)bSuccess
{
    BOOL bRet = NO;
    
    if (nil != operation.operationCallID)
    {
        //
        //  inject js for callback
        //
        NSString *injectJS4Callback = [NSString stringWithFormat:CALLBACKJSFORMAT, operation.operationCallID, parameters, [NSNumber numberWithBool:bSuccess]];
        
        [webViewController evaluateJSString:injectJS4Callback withCompletionHandler:nil];
    }
    
    return bRet;
}

#pragma mark - Private Method

/**
 *  Create ZSHyOperation object from URL request
 *
 *  @param request              the redirect url request
 *  @param webViewController    webViewController
 *  @param handler              the handler to handle the process after operation object completed retrieved
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromURLRequest:(NSURLRequest *)request
                                   fromWeb:(ZSHyWebViewController *)webViewController
                       withCompleteHandler:(void (^)(void))handler
{
    ZSHyOperation *retOperation = nil;
    
    if ([request.HTTPMethod isEqualToString:@"GET"])
    {
        retOperation = [self operationFromGetURLRequest:request fromWeb:webViewController withCompleteHandler:handler];
    }
    else if ([request.HTTPMethod isEqualToString:@"POST"])
    {
        retOperation = [self operationFromPostURLRequest:request withHandler:handler];
    }
    
    return retOperation;
}

/**
 *  Create ZSHyOperation object from Post URL request
 *
 *  @param request the redirect url request
 *  @param handler the handler to handle the process after operation object completed retrieved
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromPostURLRequest:(NSURLRequest *)request withHandler:(void (^)(void))handler
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
 *  @param request the webviewcontroller
 *  @param handler the handler to handle the process after operation object completed retrieved
 *
 *  @return ZSHyOperation object
 */
- (ZSHyOperation *)operationFromGetURLRequest:(NSURLRequest *)request
                                      fromWeb:(ZSHyWebViewController *)webViewController
                          withCompleteHandler:(void (^)(void))handler
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
            [self fetchParameterThroughJavaScript:request.URL.query fromWebViewController:webViewController forOperation:&retOperation withHanlder:handler];
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
 *  @param urlQuery             url query
 *  @param webViewController    webViewController
 *  @param operation            output operation
 *  @param handler              the handler to handle the process after operation object completed retrieved
 */
- (void)fetchParameterThroughJavaScript:(NSString *)urlQuery
                  fromWebViewController:(ZSHyWebViewController *)webViewController
                           forOperation:(ZSHyOperation **)operation
                            withHanlder:(void (^)(void))handler
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
            
            __weak ZSHyOperation *weakOperation = *operation;
            
            [webViewController evaluateJSString:injectJS4Parameter withCompletionHandler:^(NSString *result)
            {
                __strong ZSHyOperation *strongOperation = weakOperation;
                
                //
                //  JSON string or just like form submit?
                //
                (strongOperation).operationParameters = [self parseDataString2Dictionary:result];
                
                if (nil != handler)
                {
                    handler();
                }
            }];
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
