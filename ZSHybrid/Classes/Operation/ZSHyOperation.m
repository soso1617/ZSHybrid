//
//  ZSHyOperation.m
//  ParkPlatform
//
//  Created by SoSo. on 6/24/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import "ZSHyOperation.h"

/*********************************************************************
 *
 *  class ZSHyOperation
 *
 *********************************************************************/

@implementation ZSHyOperation

/**
 *  init
 *
 *  @return self instance
 */
- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _operationMode = OM_REDIRECT;
    }
    
    return self;
}

@end
