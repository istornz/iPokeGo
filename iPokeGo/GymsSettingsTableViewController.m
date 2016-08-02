//
//  GymsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "GymsSettingsTableViewController.h"

@interface GymsSettingsTableViewController ()

@end

@implementation GymsSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self readSavedState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)readSavedState
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [self.isVisibleGymsOnMapSwitch setOn:[prefs boolForKey:@"display_gyms"]];
}

-(IBAction)swicthsAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.isVisibleGymsOnMapSwitch) {
        [prefs setBool:self.isVisibleGymsOnMapSwitch.on forKey:@"display_gyms"];
    }
    
    [prefs synchronize];
}

@end
