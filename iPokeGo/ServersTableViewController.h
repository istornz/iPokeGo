//
//  ServersTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 04/09/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"
#import "ServersTableViewCell.h"

@interface ServersTableViewController : UITableViewController

@property(weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property(strong, nonatomic) NSArray *serversArray;

@property(strong, nonatomic) NSMutableArray *serversPokemonGoMapArray;
@property(strong, nonatomic) NSMutableArray *serversPogomArray;

-(IBAction)addAction:(id)sender;

@end
