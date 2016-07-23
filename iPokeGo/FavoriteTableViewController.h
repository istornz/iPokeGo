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

@interface FavoriteTableViewController : UITableViewController
{
    BOOL found;
}

@property(strong, nonatomic) NSMutableArray *pokemonID;
@property(strong, nonatomic) NSMutableArray *pokemonChecked;
@property(strong, nonatomic) NSMutableArray *pokemonFavorite;
@property(strong, nonatomic) NSDictionary *localization;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

-(IBAction)saveAction:(id)sender;

@end
