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
#import "SettingsTableViewController.h"

@interface AppDelegate() <CLLocationManagerDelegate>

@property NSTimer *dateUpdateTimer;
@property NSTimer *dataFetchTimer;
@property NSTimer *dataCleanTimer;
@property iPokeServerSync *server;
@property PokemonNotifier *notifier;
@property CLLocationManager *backgroundManager;

@end

@implementation AppDelegate

NSString * const AppDelegateNotificationTapped = @"Poke.AppDelegateNotificationTapped";

dispatch_queue_t AppDelegateCleanerQueue;
dispatch_queue_t AppDelegateFetcherQueue;
static NSTimeInterval AppDelegateTimerRefreshFrequency = 1.0;
static NSTimeInterval AppDelegateTimerCleanFrequency = 1.0;
static NSTimeInterval AppDelegatServerRefreshFrequency = 5.0;
static NSTimeInterval AppDelegatServerRefreshFrequencyBackground = 20.0;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AppDelegateCleanerQueue = dispatch_queue_create("iPoke.cleaner", NULL);
    AppDelegateFetcherQueue = dispatch_queue_create("iPoke.fetcher", NULL);
    dispatch_set_target_queue(AppDelegateCleanerQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    dispatch_set_target_queue(AppDelegateFetcherQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
    NSDictionary* defaults = @{@"display_onlyfav": @"NO",
                               @"display_common": @"NO",
                               @"display_pokemons": @"YES",
                               @"display_pokestops": @"NO",
                               @"display_gyms" : @"NO",
                               @"display_distance" : @"NO",
                               @"display_time" : @"NO",
                               @"display_timer" : @"NO",
                               @"vibration": @"YES",
                               @"fav_notification": @"YES",
                               @"norm_notification": @"NO" };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.server = [[iPokeServerSync alloc] init];
    self.notifier = [[PokemonNotifier alloc] init];
    self.backgroundManager = [[CLLocationManager alloc] init];
    
    //used for keeping the app alive in the background
    self.backgroundManager.delegate = self;
    self.backgroundManager.pausesLocationUpdatesAutomatically = NO;
    self.backgroundManager.activityType = CLActivityTypeFitness;
    self.backgroundManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; //lets try to keep this light
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        BOOL backgroundUpdate = YES;
        NSMethodSignature* signature = [[CLLocationManager class] instanceMethodSignatureForSelector:@selector(setAllowsBackgroundLocationUpdates:)];
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self.backgroundManager];
        [invocation setSelector:@selector(setAllowsBackgroundLocationUpdates:)];
        [invocation setArgument:&backgroundUpdate atIndex:2];
        [invocation invoke];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverChanged:) name:ServerChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBackgrounder) name:BackgroundSettingChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTapped:) name:AppDelegateNotificationTapped object:nil];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Notifications
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.notifier.mapViewController = ((UINavigationController *)self.window.rootViewController).viewControllers.firstObject;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.dateUpdateTimer invalidate];
    self.dateUpdateTimer = nil;
    
    //we can kill this in the background, the server should keep things clean
    [self.dataCleanTimer invalidate];
    self.dataCleanTimer = nil;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"run_in_background"]) {
        [self.dataFetchTimer invalidate];
        self.dataFetchTimer = nil;
        
    } else {
        //if we're going into the background lets try to slow down the notifications a bit to save battery
        //for now we'll use once every 20 seconds or so for a check
        [self.dataFetchTimer invalidate];
        self.dataFetchTimer = [NSTimer timerWithTimeInterval:AppDelegatServerRefreshFrequencyBackground target:self selector:@selector(refreshDataFromServer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.dataFetchTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    
    [self updateDateText];
    self.dateUpdateTimer = [NSTimer timerWithTimeInterval:AppDelegateTimerRefreshFrequency target:self selector:@selector(updateDateText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.dateUpdateTimer forMode:NSRunLoopCommonModes];
    
    if (!self.dataFetchTimer || self.dataFetchTimer.timeInterval == AppDelegatServerRefreshFrequencyBackground) {
        [self refreshDataFromServer];
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

-(void)notificationTapped:(NSNotification *)notification
{
    [self.notifier notificationTapped:notification];
}

- (void)refreshDataFromServer
{
    dispatch_async(AppDelegateFetcherQueue, ^{
        [self.server fetchData];
    });
}

- (void)cleanData
{
    dispatch_async(AppDelegateCleanerQueue, ^{
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

- (void)serverChanged:(NSNotification *)notification
{
    [self refreshDataFromServer];
}

#pragma mark - Hack background mode

- (void)updateBackgrounder
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"run_in_background"]) {
        [self.backgroundManager requestAlwaysAuthorization];
        [self.backgroundManager startUpdatingLocation];
        
    } else {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.backgroundManager stopUpdatingLocation];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways && [[NSUserDefaults standardUserDefaults] boolForKey:@"run_in_background"]) {
        [self.backgroundManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //Nothing to do here, it's just a keepalive
}

@end
