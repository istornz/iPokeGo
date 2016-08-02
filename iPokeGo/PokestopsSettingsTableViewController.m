//
//  PokestopsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokestopsSettingsTableViewController.h"

@interface PokestopsSettingsTableViewController ()

@end

@implementation PokestopsSettingsTableViewController

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

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.isVisiblePokestopsOnMapSwitch setOn:[prefs boolForKey:@"display_pokestops"]];
    [self.viewOnlyLuredSwitch setOn:[prefs boolForKey:@"display_onlylured"]];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.isVisiblePokestopsOnMapSwitch) {
        [prefs setBool:self.isVisiblePokestopsOnMapSwitch.on forKey:@"display_pokestops"];
    } else if (sender == self.viewOnlyLuredSwitch) {
        [prefs setBool:self.viewOnlyLuredSwitch.on forKey:@"display_onlylured"];
    }
    
    [prefs synchronize];
}

@end
