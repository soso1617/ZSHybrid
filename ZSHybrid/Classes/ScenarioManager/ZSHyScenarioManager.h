//
//  ZSHyManager.h
//  ParkPlatform
//
//  Created by SoSo. on 6/3/16.
//  Copyright © 2016 SoSo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ZSHyOperationCenter.h"
#import "ZSHyWebViewController.h"

/*********************************************************************
 *
 *  class ZSHyManager
 *
 *********************************************************************/

@protocol ZSHyScenarioDelegate <NSObject>

@required

/**
 *  ZSHyManager sub-class should override this method and return a specified title
 *
 *  @return return title for view controller
 */
- (NSString *)title;

/**
 *  ZSHyManager sub-class should override this method to load the specified url for webview
 *
 *  @return URL string
 */
- (NSString *)webPageURLString;

@end

typedef NS_ENUM(NSUInteger, ScenarioOpenMode)
{
    SOM_Present,
    SOM_Push,
    SOM_Default = SOM_Present
};

@interface ZSHyScenarioManager : NSObject <ZSHyScenarioDelegate, ZSHyOperationDelegate>

@property (nonatomic, readonly) ZSHyWebViewController *webViewController; // viewController

/**
 *  Singleton init
 *
 *  @return hybrid manager instance
 */
+ (instancetype)sharedManager;

/**
 *  Get specified manager by manager name
 *
 *  @param name manager name
 *
 *  @return A sub-class instance
 */
+ (instancetype)managerByName:(const NSString *)name;

/**
 *  Load secnario and present scenarios view with open mode
 *
 *  @param viewController The view controller to open scencario
 *  @param mode           ScenarioOpenMode, if using Push mode, the viewController should be contained 
 *                        in a navigationViewController.
 *                        Otherwise, you should prepare the close button for presenting mode.
 */
- (void)loadScenarioFromViewController:(UIViewController *)viewController openMode:(ScenarioOpenMode)mode;

/**
 *  Callback to webview from operation callback name
 *
 *  @param operation operation
 *  @param message   callback to web message/parameter (could use JSON string)
 #  @param bSuccess  call successful or failed function in JS
 */
- (void)invokeCallbackToWeb:(ZSHyOperation *)operation
          withMessageString:(NSString *)message
                successFlag:(BOOL)bSuccess;

@end
