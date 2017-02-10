//
//  SettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

NSString * const SettingsChangedNotification            = @"Poke.SettingsChangedNotification";
NSString * const ServerChangedNotification              = @"Poke.ServerChangedNotification";
NSString * const BackgroundSettingChangedNotification   = @"Poke.BackgroundSettingChangedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    NSString *versionInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.footerLabel.text = [NSString stringWithFormat:@"iPokeGO v%@\nCopyright (c) 2016 Dimitri Dessus\nMade with ♥️", versionInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self readSavedState];
}

-(void)readSavedState
{
    NSUserDefaults *prefs   = [NSUserDefaults standardUserDefaults];
    
    NSString *server_name = [prefs valueForKey:@"server_name"];
    if([server_name length] == 0)
    {
        self.serverTextLabel.textColor = [UIColor grayColor];
        self.serverTextLabel.text = @"Empty";
    }
    else
    {
        self.serverTextLabel.textColor = [UIColor colorWithRed:0.30 green:0.58 blue:1.00 alpha:1.0];
        self.serverTextLabel.text = server_name;
    }
    
    
    [self.backgroundSwitch setOn:[prefs boolForKey:@"run_in_background"]];
    [self.wifiSwitch setOn:[prefs boolForKey:@"wifi_only"]];
    [self.folloLocationSwitch setOn:[prefs boolForKey:@"follow_location"]];
    
    NSString *drivingMode = [prefs objectForKey:@"driving_mode"];
    if ([drivingMode isEqualToString:@"MKLaunchOptionsDirectionsModeTransit"])
        self.drivingModeLabel.text = NSLocalizedString(@"Transit", nil);
    else if ([drivingMode isEqualToString:@"MKLaunchOptionsDirectionsModeWalking"])
        self.drivingModeLabel.text = NSLocalizedString(@"Walk", nil);
    else
        self.drivingModeLabel.text = NSLocalizedString(@"Car", nil);
}

-(IBAction)saveAction:(UIBarButtonItem *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setBool:self.folloLocationSwitch.on forKey:@"follow_location"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ServerForceReloadData object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.backgroundSwitch) {
        [prefs setBool:self.backgroundSwitch.on forKey:@"run_in_background"];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackgroundSettingChangedNotification object:nil];
    }
    else if (sender == self.wifiSwitch) {
        [prefs setBool:self.wifiSwitch.on forKey:@"wifi_only"];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackgroundSettingChangedNotification object:nil];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == CELL_INDEX_DRIVINGMODE && indexPath.section == 0)
    {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Select a drive mode", @"The title of an alert that tells the user to select a new drive mode")
                                    message:NSLocalizedString(@"Please select a mode", @"The message of an alert that tells the user to select a new drive mode")
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *drive = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Drive", @"A button to set driving mode on map")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [[NSUserDefaults standardUserDefaults] setObject:@"MKLaunchOptionsDirectionsModeDriving" forKey:@"driving_mode"];
                                       self.drivingModeLabel.text = NSLocalizedString(@"car", nil);
                                   }];
        UIAlertAction *bike = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Transit", @"A button to set transit mode on map")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [[NSUserDefaults standardUserDefaults] setObject:@"MKLaunchOptionsDirectionsModeTransit" forKey:@"driving_mode"];
                                       self.drivingModeLabel.text = NSLocalizedString(@"transit", nil);
                                   }];
        UIAlertAction *walk = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Walk", @"A button to set walking mode on map")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [[NSUserDefaults standardUserDefaults] setObject:@"MKLaunchOptionsDirectionsModeWalking" forKey:@"driving_mode"];
                                       self.drivingModeLabel.text = NSLocalizedString(@"walk", nil);
                                   }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", @"A button to destroy the alert without saving")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:drive];
        [alert addAction:bike];
        [alert addAction:walk];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
