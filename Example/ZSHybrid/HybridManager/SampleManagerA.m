//
//  SampleManagerA.m
//  ZSHybrid
//
//  Created by SoSo. on 9/1/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import "SampleManagerA.h"

#define RegisterOperationNameA      @"InterfaceA"   // web side will call this as host name
#define RegisterOperationNameB      @"InterfaceB"   // web side will call this as host name

@implementation SampleManagerA

- (NSString *)title
{
    return @"Sample";
}

- (NSString *)webPageURLString
{
    NSString *filePath = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"].path;
    
    return filePath;
}

- (NSArray *)registerOperationsNames
{
    return @[RegisterOperationNameA, RegisterOperationNameB];
}

- (void)loadScenarioFromViewController:(UIViewController *)viewController
                              openMode:(ScenarioOpenMode)mode
                            completion:(void (^)())completion
{
    [super loadScenarioFromViewController:viewController openMode:mode completion:completion];
    
    //
    //  override load local page, since wkwebview doesn't support loadRequest from local
    //
    NSString *filePath = [NSString stringWithFormat:@"file://%@", self.webPageURLString];
    
    [self.webViewController.webView loadFileURL:[NSURL URLWithString:filePath] allowingReadAccessToURL:[NSURL URLWithString:filePath.stringByDeletingLastPathComponent]];
}

- (BOOL)handleOperation:(ZSHyOperation *)operation
{
    if ([operation.operationName isEqualToString:RegisterOperationNameA])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hybrid" message:operation.operationDictParameters[@"value"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        //
                                        //  callback to webview
                                        //
                                        [self invokeCallbackToWeb:operation withMessageString:@"Hello sample" successFlag:YES];
                                    }]];
        
        [self.webViewController presentViewController:alertController animated:YES completion:nil];
    }
    else if ([operation.operationName isEqualToString:RegisterOperationNameB])
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hybrid" message:operation.operationDictParameters[@"value"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        //
                                        //  callback to webview
                                        //
                                        [self invokeCallbackToWeb:operation withMessageString:@"Failed" successFlag:NO];
                                    }]];
        [self.webViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    return YES;
}

@end
