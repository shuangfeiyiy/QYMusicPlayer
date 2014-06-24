//
//  QYAppDelegate.m
//  QYMusicPlayer
//
//  Created by zhangsf on 14-5-17.
//  Copyright (c) 2014年 zhangsf. All rights reserved.
//

#import "QYAppDelegate.h"
#import "QYViewController.h"

@implementation QYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    QYViewController *viewController = [[QYViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
