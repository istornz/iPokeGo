//
//  NotificationsSettingsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"

@interface NotificationsSettingsTableViewController : UITableViewController

@property(weak, nonatomic) IBOutlet UIImageView *normalNotificationImageView;
@property(weak, nonatomic) IBOutlet UILabel *normalNotificationLabel;
@property(weak, nonatomic) IBOutlet UISwitch *normalNotificationSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *favoriteNotificationImageView;
@property(weak, nonatomic) IBOutlet UILabel *favoriteNotificationLabel;
@property(weak, nonatomic) IBOutlet UISwitch *favoriteNotificationSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *vibrationImageView;
@property(weak, nonatomic) IBOutlet UILabel *vibrationLabel;
@property(weak, nonatomic) IBOutlet UISwitch *vibrationSwitch;

-(IBAction)switchAction:(UISwitch *)sender;

@end
