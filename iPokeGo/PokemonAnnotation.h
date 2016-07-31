//
//  PokemonAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PokemonAnnotation : MKPointAnnotation

@property int pokemonID;
@property BOOL hidePokemon;
@property BOOL isFav;
@property NSDate *expirationDate;
@property NSString *spawnpointID;
@property NSString *encounterID;

-(PokemonAnnotation *)initWithJson:(NSDictionary *)data;

@end
