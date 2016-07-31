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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
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
        case SWITCH_COMMON:
            [prefs setObject:[NSNumber numberWithBool:self.commonSwitch.on] forKey:@"display_common"];
            break;
        case SWITCH_DISTANCE:
            [prefs setObject:[NSNumber numberWithBool:self.distanceSwitch.on] forKey:@"display_distance"];
            break;
        case SWITCH_TIME:
            [prefs setObject:[NSNumber numberWithBool:self.timeSwitch.on] forKey:@"display_time"];
            break;
        case SWITCH_TIMETIMER:
            [prefs setObject:[NSNumber numberWithBool:self.timeTimerSwitch.on] forKey:@"display_timer"];
            break;
        case SWITCH_ONLYFAV:
            if(self.viewOnlyFavoriteSwitch.on)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSArray *pokemonListSaved = [defaults objectForKey:@"pokemon_favorite"];
                
                if([pokemonListSaved count] == 0)
                {
                    [self.viewOnlyFavoriteSwitch setOn:NO];
                    
                    UIAlertController *alert = [UIAlertController
                                                alertControllerWithTitle:NSLocalizedString(@"Be carreful !", @"The title of an alert that tells the user, that no favorite pokemon is already set.")
                                                message:NSLocalizedString(@"You don't have any favorite pokemon.\nPlease go add some Pokemon in Settings", @"The message of an alert that tells the user, that no favorite pokemon is already set.")
                                                preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *ok = [UIAlertAction
                                         actionWithTitle:NSLocalizedString(@"OK", @"A common affirmative action title, like 'OK' in english.")
                                         style:UIAlertActionStyleDefault
                                         handler:nil];
                    
                    [alert addAction:ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
            [prefs setObject:[NSNumber numberWithBool:self.viewOnlyFavoriteSwitch.on] forKey:@"display_onlyfav"];
            
            break;
        default:
            // Nothing
            break;
    }
    
    [prefs synchronize];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
