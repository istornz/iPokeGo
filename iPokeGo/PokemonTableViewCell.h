//
//  PokemonTableViewCell.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 23/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PokemonTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIImageView *pokemonimageView;
@property(weak, nonatomic) IBOutlet UILabel *pokemonName;

@end
