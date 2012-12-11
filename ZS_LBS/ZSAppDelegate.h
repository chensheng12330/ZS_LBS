//
//  ZSAppDelegate.h
//  ZS_LBS
//
//  Created by Sherwin.Chen on 12-12-11.
//  Copyright (c) 2012年 Sherwin.Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@class ZSViewController;

@interface ZSAppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ZSViewController *viewController;

@property (strong, nonatomic) UINavigationController *navController;
@end
