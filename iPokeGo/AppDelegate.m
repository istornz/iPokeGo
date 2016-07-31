//
//  AppDelegate.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "AppDelegate.h"
#import "TimerLabel.h"
#import "iPokeServerSync.h"
#import "CoreDataPersistance.h"
#import "CoreDataEntities.h"
#import "PokemonNotifier.h"

@interface AppDelegate()

@property NSTimer *dateUpdateTimer;
@property NSTimer *dataFetchTimer;
@property NSTimer *dataCleanTimer;
@property iPokeServerSync *server;
@property PokemonNotifier *notifier;
@property UIBackgroundTaskIdentifier bgTask;

@end

@implementation AppDelegate

NSString * const AppDelegateNotificationTapped = @"Poke.AppDelegateNotificationTapped";

static NSTimeInterval AppDelegateTimerRefreshFrequency = 1.0;
static NSTimeInterval AppDelegateTimerCleanFrequency = 1.0;
static NSTimeInterval AppDelegatServerRefreshFrequency = 5.0;

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
    
    self.server = [[iPokeServerSync alloc] init];
    self.notifier = [[PokemonNotifier alloc] init];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Notifications
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|
                                                       UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.notifier.mapViewController = ((UINavigationController *)self.window.rootViewController).viewControllers.firstObject;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.dateUpdateTimer invalidate];
    self.dateUpdateTimer = nil;
    
    //these need to go back in if the background hack is removed
//    [self.dataFetchTimer invalidate];
//    self.dataFetchTimer = nil;
//    
//    [self.dataCleanTimer invalidate];
//    self.dataCleanTimer = nil;
    
    [self keepAlive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    
    [self updateDateText];
    self.dateUpdateTimer = [NSTimer timerWithTimeInterval:AppDelegateTimerRefreshFrequency target:self selector:@selector(updateDateText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.dateUpdateTimer forMode:NSRunLoopCommonModes];
    
    if (!self.dataFetchTimer) {
        [self refreshDataFromServer];
        [self.server fetchData];
        self.dataFetchTimer = [NSTimer timerWithTimeInterval:AppDelegatServerRefreshFrequency target:self selector:@selector(refreshDataFromServer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.dataFetchTimer forMode:NSDefaultRunLoopMode];
    }
    
    if (!self.dataCleanTimer) {
        [self cleanData];
        self.dataCleanTimer = [NSTimer timerWithTimeInterval:AppDelegateTimerCleanFrequency target:self selector:@selector(cleanData) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.dataCleanTimer forMode:NSDefaultRunLoopMode];
    }
}

#pragma mark Local notification delegate

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    if (appState != UIApplicationStateActive) {
        NSLog(@"Notification touched !");
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNotificationTapped
                                                            object:self
                                                          userInfo:notification.userInfo];
    }
}

- (void)refreshDataFromServer
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.server fetchData];
    });
}

- (void)cleanData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext *context = [[CoreDataPersistance sharedInstance] newWorkerContext];
        NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
        [itemsToDeleteRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass([Pokemon class]) inManagedObjectContext:context]];
        [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"self.disappears < %@" argumentArray:@[[NSDate date]]]];
        [itemsToDeleteRequest setIncludesPropertyValues:NO];
        NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
        if (itemsToDelete.count > 0) {
            NSLog(@"Purging %@ old pokemon", @(itemsToDelete.count));
        }
        for (NSManagedObject *itemToDelete in itemsToDelete) {
            [context deleteObject:itemToDelete];
        }
        [[CoreDataPersistance sharedInstance] commitChangesAndDiscardContext:context];
    });
}

- (void)updateDateText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TimerLabelUpdateNotification object:nil];
}

#pragma mark - Hack background mode

//TODO: Find a legal way to make the background task infinite or more longer than 3min
- (void)keepAlive {
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        [self keepAlive];
    }];
}

- (void)appForegrounding: (NSNotification *)notification {
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

@end
