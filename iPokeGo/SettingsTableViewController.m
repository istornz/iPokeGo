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
    
    self.serverField.text   = [prefs valueForKey:@"server_addr"];
	self.usernameField.text = [prefs valueForKey:@"server_user"];
	self.passwordField.text = [prefs valueForKey:@"server_pass"];
    
    [self.backgroundSwitch setOn:[prefs boolForKey:@"run_in_background"]];
    
    NSString *drivingMode = [prefs objectForKey:@"driving_mode"];
    if ([drivingMode isEqualToString:@"MKLaunchOptionsDirectionsModeTransit"])
        self.drivingModeLabel.text = NSLocalizedString(@"Transit", nil);
    else if ([drivingMode isEqualToString:@"MKLaunchOptionsDirectionsModeWalking"])
        self.drivingModeLabel.text = NSLocalizedString(@"Walk", nil);
    else
        self.drivingModeLabel.text = NSLocalizedString(@"Car", nil);
    
    NSString *serverType = [prefs valueForKey:@"server_type"];
    if ([serverType isEqualToString:SERVER_API_DATA_POGOM])
        self.serverTypeLabel.text = @"Pogom";
    else
        self.serverTypeLabel.text = @"PokemonGo-Map";
    
}

-(IBAction)saveAction:(UIBarButtonItem *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSString *server_addr = [self.serverField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![server_addr containsString:@"://"] && server_addr.length > 0) {
        server_addr = [NSString stringWithFormat:@"http://%@", server_addr];
        self.serverField.text = server_addr;
    }
	
	NSString *server_user = self.usernameField.text;
	if (![[prefs objectForKey:@"server_user"] isEqualToString:server_user]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
		[prefs setObject:server_user forKey:@"server_user"];
	}
	
	NSString *server_pass = self.passwordField.text;
	if (![[prefs objectForKey:@"server_pass"] isEqualToString:server_user]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
		[prefs setObject:server_pass forKey:@"server_pass"];
	}
	
    if (![[prefs objectForKey:@"server_addr"] isEqualToString:server_addr]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
        [prefs setObject:server_addr forKey:@"server_addr"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingsChangedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.backgroundSwitch) {
        [prefs setBool:self.backgroundSwitch.on forKey:@"run_in_background"];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackgroundSettingChangedNotification object:nil];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == CELL_INDEX_SERVERTYPE && indexPath.section == 0)
    {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Select a server type", @"The title of an alert that tells the user to select a server type")
                                    message:NSLocalizedString(@"Please select a type", @"The message of an alert that tells the user to select a new server type")
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *pokemongomap = [UIAlertAction
                                actionWithTitle:@"PokemonGo-Map"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [[NSUserDefaults standardUserDefaults] setObject:SERVER_API_DATA_POKEMONGOMAP forKey:@"server_type"];
                                    self.serverTypeLabel.text = @"PokemonGo-Map";
                                    [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
                                }];
        UIAlertAction *pogom = [UIAlertAction
                               actionWithTitle:@"Pogom"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [[NSUserDefaults standardUserDefaults] setObject:SERVER_API_DATA_POGOM forKey:@"server_type"];
                                   self.serverTypeLabel.text = @"Pogom";
                                   [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
                               }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", @"A button to destroy the alert without saving")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:pokemongomap];
        [alert addAction:pogom];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if(indexPath.row == CELL_INDEX_DRIVINGMODE && indexPath.section == 0)
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.serverField)
        [self.usernameField becomeFirstResponder];
    else if(textField == self.usernameField)
        [self.passwordField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

@end
