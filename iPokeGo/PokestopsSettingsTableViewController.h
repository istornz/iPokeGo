//
//  PokestopsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PokestopsSettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *isVisiblePokestopsOnMapImageView;
@property (weak, nonatomic) IBOutlet UILabel *isVisiblePokestopsOnMapLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isVisiblePokestopsOnMapSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *viewOnlyLuredImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewOnlyLuredLabel;
@property (weak, nonatomic) IBOutlet UISwitch *viewOnlyLuredSwitch;

-(IBAction)swicthsAction:(UISwitch *)sender;

@end
