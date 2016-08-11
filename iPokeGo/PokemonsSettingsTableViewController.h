//
//  PokemonSettingsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PokemonSelectTableViewController.h"

@interface PokemonsSettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *isVisiblePokemonsOnMapImageView;
@property (weak, nonatomic) IBOutlet UILabel *isVisiblePokemonsOnMapLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isVisiblePokemonsOnMapSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *commonImageView;
@property (weak, nonatomic) IBOutlet UILabel *commonLabel;
@property (weak, nonatomic) IBOutlet UISwitch *commonSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *viewOnlyFavoriteImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewOnlyFavoriteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *viewOnlyFavoriteSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *distanceImageView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *distanceSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *timeSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *timeTimerImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeTimerLabel;
@property (weak, nonatomic) IBOutlet UISwitch *timeTimerSwitch;

-(IBAction)swicthsAction:(UISwitch *)sender;

@end
