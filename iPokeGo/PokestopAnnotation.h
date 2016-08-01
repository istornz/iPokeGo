//
//  PokestopAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CoreDataEntities.h"

@interface PokestopAnnotation : MKPointAnnotation

@property NSString *pokestopID;
@property BOOL hasLure;
@property int luredPokemonID;

- (instancetype)initWithPokestop:(PokeStop *)pokeStop;

@end
