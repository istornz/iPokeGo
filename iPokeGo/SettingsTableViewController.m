//
//  SettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "PokemonSelectTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

NSString * const SettingsChangedNotification = @"Poke.SettingsChangedNotification";
NSString * const ServerChangedNotification = @"Poke.ServerChangedNotification";
NSString * const BackgroundSettingChangedNotification = @"Poke.BackgroundSettingChangedNotification";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_favorite"] count] == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"display_onlyfav"];
    }
    
    [self readSavedState];
}

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.serverField.text = [prefs valueForKey:@"server_addr"];
    
    [self.pokemonsSwitch setOn:[prefs boolForKey:@"display_pokemons"]];
    [self.pokestopsSwitch setOn:[prefs boolForKey:@"display_pokestops"]];
    [self.gymsSwitch setOn:[prefs boolForKey:@"display_gyms"]];
    [self.commonSwitch setOn:[prefs boolForKey:@"display_common"]];
    [self.viewOnlyFavoriteSwitch setOn:[prefs boolForKey:@"display_onlyfav"]];
    [self.distanceSwitch setOn:[prefs boolForKey:@"display_distance"]];
    [self.timeSwitch setOn:[prefs boolForKey:@"display_time"]];
    [self.timeTimerSwitch setOn:[prefs boolForKey:@"display_timer"]];
    [self.backgroundSwitch setOn:[prefs boolForKey:@"run_in_background"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       // Run in background thread to prevent little freeze
        if ([[prefs objectForKey:@"pokemon_favorite"] count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewOnlyFavoriteSwitch setOn:YES];
            });
        }
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if([segue.identifier isEqualToString:@"showPokemonSelect"]) {
		PokemonSelectTableViewController *destViewController = segue.destinationViewController;

		switch (((UITableViewCell *)sender).tag) {
			case SELECT_COMMON:
				destViewController.title = NSLocalizedString(@"Common", @"The title of the Pokémon selection for common Pokémon.") ;
				destViewController.preferenceKey = @"pokemon_common";
				break;
			case SELECT_FAVORITE:
				destViewController.title = NSLocalizedString(@"Favorite", @"The title of the Pokémon selection for favorite Pokémon.");
				destViewController.preferenceKey = @"pokemon_favorite";
				break;
			default:
				break;
		}
	}
}

-(IBAction)closeAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveAction:(UIBarButtonItem *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *server = [self.serverField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([server length] > 0) {
        if (![[prefs objectForKey:@"server_addr"] isEqualToString:server]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ServerChangedNotification object:nil];
            [prefs setObject:self.serverField.text forKey:@"server_addr"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingsChangedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.pokemonsSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.pokemonsSwitch.on] forKey:@"display_pokemons"];
        
    } else if (sender == self.gymsSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.gymsSwitch.on] forKey:@"display_gyms"];
        
    } else if (sender == self.commonSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.commonSwitch.on] forKey:@"display_common"];
        
    } else if (sender == self.distanceSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.distanceSwitch.on] forKey:@"display_distance"];
        
    } else if (sender == self.timeSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.timeSwitch.on] forKey:@"display_time"];
        
    } else if (sender == self.timeTimerSwitch) {
        //confusing when the user enabled this but doesn't see anything because display_time isn't on
        //enable that as a byproduct of enabling this
        if (self.timeTimerSwitch.on) {
            self.timeSwitch.on = YES;
            [prefs setObject:[NSNumber numberWithBool:self.timeSwitch.on] forKey:@"display_time"];
        }
        [prefs setObject:[NSNumber numberWithBool:self.timeTimerSwitch.on] forKey:@"display_timer"];
        
    } else if (sender == self.viewOnlyFavoriteSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.viewOnlyFavoriteSwitch.on] forKey:@"display_onlyfav"];
        
    } else if (sender == self.backgroundSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.backgroundSwitch.on] forKey:@"run_in_background"];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackgroundSettingChangedNotification object:nil];
    } else if (sender == self.pokestopsSwitch) {
        [prefs setObject:[NSNumber numberWithBool:self.pokestopsSwitch.on] forKey:@"display_pokestops"];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
