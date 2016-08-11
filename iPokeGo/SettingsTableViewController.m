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
