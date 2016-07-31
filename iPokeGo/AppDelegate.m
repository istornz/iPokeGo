//
//  AppDelegate.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "AppDelegate.h"
#import "TimerLabel.h"

@interface AppDelegate()

@property (nonatomic) NSTimer *dateUpdateTimer;

@end

@implementation AppDelegate

static NSTimeInterval AppDelegateTimerRefreshFrequency = 1.0;
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary* defaults = @{@"display_onlyfav": @"YES",
                               @"display_common": @"NO",
                               @"display_pokemons": @"YES",
                               @"display_pokestops": @"NO",
                               @"display_gyms" : @"NO",
                               @"display_distance" : @"NO",
                               @"display_time" : @"NO",
                               @"display_timer" : @"NO"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Notifications
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [self.dateUpdateTimer invalidate];
    self.dateUpdateTimer = nil;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
    
    [self updateDateText];
    self.dateUpdateTimer = [NSTimer timerWithTimeInterval:AppDelegateTimerRefreshFrequency target:self selector:@selector(updateDateText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.dateUpdateTimer forMode:NSRunLoopCommonModes];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Local notification delegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)])
        appState = application.applicationState;
    
    if (appState != UIApplicationStateActive)
    {
        NSLog(@"Notification touched !");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showAnnotationFromLocalNotif"
                                                            object:self
                                                          userInfo:notification.userInfo];
    }
}

- (void)updateDateText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TimerLabelUpdateNotification object:nil];
}

@end
