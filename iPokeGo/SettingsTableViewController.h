//
//  SettingsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"
#import "iPokeServerSync.h"

#define CELL_INDEX_DRIVINGMODE  5

extern NSString * const SettingsChangedNotification;
extern NSString * const ServerChangedNotification;
extern NSString * const BackgroundSettingChangedNotification;

@interface SettingsTableViewController : UITableViewController <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *fermerButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property(weak, nonatomic) IBOutlet UIImageView *serverImageView;
@property(weak, nonatomic) IBOutlet UILabel *serverLabel;
@property(weak, nonatomic) IBOutlet UILabel *serverTextLabel;

@property(weak, nonatomic) IBOutlet UILabel *drivingModeLabel;

@property(weak, nonatomic) IBOutlet UIImageView *pokemonsImageView;
@property(weak, nonatomic) IBOutlet UILabel *pokemonsLabel;

@property(weak, nonatomic) IBOutlet UIImageView *pokestopsImageView;
@property(weak, nonatomic) IBOutlet UILabel *pokestopsLabel;

@property(weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property(weak, nonatomic) IBOutlet UILabel *backgroundLabel;
@property(weak, nonatomic) IBOutlet UISwitch *backgroundSwitch;

@property(weak, nonatomic) IBOutlet UISwitch *wifiSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *folloLocationImageView;
@property(weak, nonatomic) IBOutlet UILabel *folloLocationLabel;
@property(weak, nonatomic) IBOutlet UISwitch *folloLocationSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *gymsImageView;
@property(weak, nonatomic) IBOutlet UILabel *gymsLabel;

@property(weak, nonatomic) IBOutlet UIImageView *licenseImageView;
@property(weak, nonatomic) IBOutlet UILabel *licenseLabel;

@property(weak, nonatomic) IBOutlet UILabel *footerLabel;

-(IBAction)saveAction:(UIBarButtonItem *)sender;
-(IBAction)swicthsAction:(UISwitch *)sender;

@end
