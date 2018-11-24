//
//  PYAppDelegate.m
//  PYMethodParser
//
//  Created by LiPengYue on 11/24/2018.
//  Copyright (c) 2018 LiPengYue. All rights reserved.
//

#import "PYAppDelegate.h"
#import <PYMethodParserHeaders.h>
@interface PYAppDelegate ()<NSCacheDelegate>

@end
@implementation PYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PYMethodParserConfig setupConfig:^(PYMethodParserGlobleConfig *config) {
       config
        .setup_globalNotFoundSELHandlerType([PYAppDelegate class])
        .setup_isPrintfLogWithMethodParserError(true)
        .setup_isPrintfLogWithMethodPraserCallMethodSuccess(true)
        .setup_isPrintf_methodParser_Boxing_Log(true)
        .setup_methodSignatureCacheDelegate(self)
        .setup_methodSignatureMaxCount(100000);
    }];
    [PYMethodParser callMethodWithTarget:self andSelName:@"cache:willEvictObject:" andError:nil,nil];
    return YES;
}
- (void) cache:(NSCache *)cache willEvictObject:(id)obj {
    
}

+ (void)py_notFoundSEL:(SEL)sel and_va_list:(va_list)list {
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
