//
//  SettingsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"

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

@property(weak, nonatomic) IBOutlet UIImageView *gymsImageView;
@property(weak, nonatomic) IBOutlet UILabel *gymsLabel;
@property(weak, nonatomic) IBOutlet UISwitch *gymsSwitch;

@property(weak, nonatomic) IBOutlet UIImageView *commonImageView;
@property(weak, nonatomic) IBOutlet UILabel *commonLabel;
@property(weak, nonatomic) IBOutlet UISwitch *commonSwitch;

-(IBAction)closeAction:(UIBarButtonItem *)sender;
-(IBAction)saveAction:(UIBarButtonItem *)sender;
-(IBAction)swicthsAction:(UISwitch *)sender;

@end
