//
//  ZSHyOperationDelegate.h
//  ParkPlatform
//
//  Created by SoSo. on 7/15/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <Foundation/Foundation.h>

/*********************************************************************
 *
 *  protocol ZSHyOperationDelegate
 *
 *********************************************************************/

@class ZSHyOperation;

@protocol ZSHyOperationDelegate <NSObject>

/**
 *  The operation names that this manager could handle.
 *  You should call registerOperation:(NSArray *)operationsNames fromHandler:(id<ZSHyOperationDelegate>)handler
 *  to register the operation.
 *
 *  @return bunch of operations names
 */
- (NSArray *)registerOperationsNames;

/**
 *  Do operation according to operation command
 *
 *  @param operation operation object
 *
 *  @return Y or N if this operation is handled by the handler
 */
- (BOOL)handleOperation:(ZSHyOperation *)operation;

@end
