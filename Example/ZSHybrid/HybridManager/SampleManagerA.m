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

- (BOOL)handleOperation:(ZSHyOperation *)operation
{
    if ([operation.operationName isEqualToString:RegisterOperationNameA])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hybrid" message:operation.operationParameters[@"value"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self.webViewController invokeCallbackToWeb:operation withMessageString:@"Hello sample" successFlag:YES];
                                    }]];
        
        [self.webViewController presentViewController:alertController animated:YES completion:nil];
    }
    else if ([operation.operationName isEqualToString:RegisterOperationNameB])
    {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Hybrid" message:operation.operationParameters[@"value"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                    {
                                        [self.webViewController invokeCallbackToWeb:operation withMessageString:@"find me" successFlag:NO];
                                    }]];
        [self.webViewController presentViewController:alertController animated:YES completion:nil];
    }
    
    return YES;
}

@end
