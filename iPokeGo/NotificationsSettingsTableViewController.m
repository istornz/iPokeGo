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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.normalNotificationSwitch.on = [prefs boolForKey:@"norm_notification"];
    self.favoriteNotificationSwitch.on = [prefs boolForKey:@"fav_notification"];
    self.vibrationSwitch.on = [prefs boolForKey:@"vibration"];
}

-(IBAction)switchAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.normalNotificationSwitch) {
        [prefs setBool:self.normalNotificationSwitch.on forKey:@"norm_notification"];
    } else if (sender == self.favoriteNotificationSwitch) {
        [prefs setBool:self.favoriteNotificationSwitch.on forKey:@"fav_notification"];
    } else if (sender == self.vibrationSwitch) {
        [prefs setBool:self.vibrationSwitch.on forKey:@"vibration"];
    }
}

@end
