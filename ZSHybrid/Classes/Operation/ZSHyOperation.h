//
//  ZSHyOperation.h
//  ParkPlatform
//
//  Created by SoSo. on 6/24/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHyOperationDelegate.h"

/**
 Enum to describe the operation mode from url redirect
 */
typedef NS_ENUM(NSUInteger, OperationMode)
{
    OM_REDIRECT,
    OM_PROCESS,
    OM_UNKNOW = OM_REDIRECT,
};

/*********************************************************************
 *
 *  class ZSHyOperation
 *
 *********************************************************************/

@interface ZSHyOperation : NSObject

@property (nonatomic) OperationMode operationMode;    // operation enum, default is HO_REDIRECT
@property (nonatomic, copy) NSString *operationName;    // the operation name
@property (nonatomic, strong) NSDictionary *operationParameters;    // dictionary contains the value which operation may need, could be nil
@property (nonatomic, strong) NSURLRequest *operationRequest;   // if object is created from url request, this property can retain that value
@property (nonatomic, weak) id<ZSHyOperationDelegate> operationHandler;   // the manager to handle this operation
@property (nonatomic, copy) NSString *operationCallID;    // the callID for this operation, this callID is the identifier for each web-native call

@end
