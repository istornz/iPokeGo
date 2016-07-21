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
    
    self.serverField.text = [prefs valueForKey:@"server_addr"];
    
    if([prefs objectForKey:@"display_pokemons"] == nil)
        [self.pokemonsSwitch setOn:YES]; // Not already set
    else
        [self.pokemonsSwitch setOn:[prefs boolForKey:@"display_pokemons"]];
    
    if([prefs objectForKey:@"display_pokestops"] == nil)
        [self.pokestopsSwitch setOn:YES]; // Not already set
    else
        [self.pokestopsSwitch setOn:[prefs boolForKey:@"display_pokestops"]];
    
    if([prefs objectForKey:@"display_gyms"] == nil)
        [self.gymsSwitch setOn:YES]; // Not already set
    else
        [self.gymsSwitch setOn:[prefs boolForKey:@"display_gyms"]];
}

-(IBAction)closeAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveAction:(UIBarButtonItem *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([self.serverField.text length] > 0)
    {
        [prefs setObject:self.serverField.text forKey:@"server_addr"];
    }
    
    [prefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    switch (sender.tag) {
        case SWITCH_POKEMON:
            [prefs setObject:[NSNumber numberWithBool:self.pokemonsSwitch.on] forKey:@"display_pokemons"];
            break;
        case SWITCH_POKESTOPS:
            [prefs setObject:[NSNumber numberWithBool:self.pokestopsSwitch.on] forKey:@"display_pokestops"];
            break;
        case SWITCH_GYMS:
            [prefs setObject:[NSNumber numberWithBool:self.gymsSwitch.on] forKey:@"display_gyms"];
            break;
            
        default:
            // Nothing
            break;
    }
    
    [prefs synchronize];
}

@end
