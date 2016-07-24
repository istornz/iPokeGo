//
//  NotificationsSettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "NotificationsSettingsTableViewController.h"

@interface NotificationsSettingsTableViewController ()

@end

@implementation NotificationsSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readSavedState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if([prefs objectForKey:@"norm_notification"] == nil)
        [self.normalNotificationSwitch setOn:YES]; // Not already set
    else
        [self.normalNotificationSwitch setOn:[prefs boolForKey:@"norm_notification"]];
    
    if([prefs objectForKey:@"fav_notification"] == nil)
        [self.favoriteNotificationSwitch setOn:YES]; // Not already set
    else
        [self.favoriteNotificationSwitch setOn:[prefs boolForKey:@"fav_notification"]];
    
}

-(IBAction)switchAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    switch (sender.tag) {
        case SWITCH_NOTIFI_NORM:
            [prefs setObject:[NSNumber numberWithBool:self.normalNotificationSwitch.on] forKey:@"norm_notification"];
            break;
        case SWITCH_NOTIFI_FAV:
            [prefs setObject:[NSNumber numberWithBool:self.favoriteNotificationSwitch.on] forKey:@"fav_notification"];
            break;
            
        default:
            // Nothing
            break;
    }
    
    [prefs synchronize];
}

@end
