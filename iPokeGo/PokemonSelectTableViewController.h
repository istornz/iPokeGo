//
//  FavoriteTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 23/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"
#import "PokemonTableViewCell.h"

@interface PokemonSelectTableViewController : UITableViewController <UISearchResultsUpdating>

@property(strong, nonatomic) NSString *preferenceKey;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

-(IBAction)saveAction:(id)sender;

@end
