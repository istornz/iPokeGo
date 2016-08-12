//
//  PokemonSettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonsSettingsTableViewController.h"

@interface PokemonsSettingsTableViewController ()

@end

@implementation PokemonsSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self readSavedState];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *favs = [[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_favorite"];
    self.viewOnlyFavoriteSwitch.enabled = [favs count] > 0;
}

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.isVisiblePokemonsOnMapSwitch setOn:[prefs boolForKey:@"display_pokemons"]];
    [self.commonSwitch setOn:[prefs boolForKey:@"display_common"]];
    [self.viewOnlyFavoriteSwitch setOn:[prefs boolForKey:@"display_onlyfav"]];
    [self.distanceSwitch setOn:[prefs boolForKey:@"display_distance"]];
    [self.timeSwitch setOn:[prefs boolForKey:@"display_time"]];
    [self.timeTimerSwitch setOn:[prefs boolForKey:@"display_timer"]];
    [self.timeTimerSwitch setEnabled:[prefs boolForKey:@"display_time"]];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.isVisiblePokemonsOnMapSwitch) {
        [prefs setBool:self.isVisiblePokemonsOnMapSwitch.on forKey:@"display_pokemons"];
    } else if (sender == self.commonSwitch) {
        [prefs setBool:self.commonSwitch.on forKey:@"display_common"];
    } else if (sender == self.viewOnlyFavoriteSwitch) {
        [prefs setBool:self.viewOnlyFavoriteSwitch.on forKey:@"display_onlyfav"];
    } else if (sender == self.distanceSwitch) {
        [prefs setBool:self.distanceSwitch.on forKey:@"display_distance"];
    } else if (sender == self.timeSwitch) {
        [prefs setBool:self.timeSwitch.on forKey:@"display_time"];
        [self.timeTimerSwitch setEnabled:self.timeSwitch.on];
    } else if (sender == self.timeTimerSwitch) {
        [prefs setBool:self.timeTimerSwitch.on forKey:@"display_timer"];
    }
    
    [prefs synchronize];
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

@end
