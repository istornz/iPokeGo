//
//  GymsTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 02/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GymsSettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *isVisibleGymsOnMapImageView;
@property (weak, nonatomic) IBOutlet UILabel *isVisibleGymsOnMapLabel;
@property (weak, nonatomic) IBOutlet UISwitch *isVisibleGymsOnMapSwitch;

-(IBAction)swicthsAction:(UISwitch *)sender;

@end
