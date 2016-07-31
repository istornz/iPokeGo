//
//  SettingsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"

extern NSString * const SettingsChangedNotification;
extern NSString * const ServerChangedNotification;

@interface SettingsTableViewController : UITableViewController

@property(weak, nonatomic) IBOutlet UIBarButtonItem *fermerButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property(weak, nonatomic) IBOutlet UIImageView *serverImageView;
@property(weak, nonatomic) IBOutlet UILabel *serverLabel;
@property(weak, nonatomic) IBOutlet UITextField *serverField;

@property(weak, nonatomic) IBOutlet UIImageView *pokemonsImageView;
@property(weak, nonatomic) IBOutlet UILabel *pokemonsLabel;
@property(weak, nonatomic) IBOutlet UISwitch *pokemonsSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *pokestopsImageView;
@property(weak, nonatomic) IBOutlet UILabel *pokestopsLabel;
@property(weak, nonatomic) IBOutlet UISwitch *pokestopsSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property(weak, nonatomic) IBOutlet UISwitch *backgroundSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *gymsImageView;
@property(weak, nonatomic) IBOutlet UILabel *gymsLabel;
@property(weak, nonatomic) IBOutlet UISwitch *gymsSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *commonImageView;
@property(weak, nonatomic) IBOutlet UILabel *commonLabel;
@property(weak, nonatomic) IBOutlet UISwitch *commonSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *viewOnlyFavoriteImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewOnlyFavoriteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *viewOnlyFavoriteSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *distanceImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *distanceSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *timeSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *timeTimerImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeTimerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *timeTimerSwitch;

-(IBAction)closeAction:(UIBarButtonItem *)sender;
-(IBAction)saveAction:(UIBarButtonItem *)sender;
-(IBAction)swicthsAction:(UISwitch *)sender;

@end
