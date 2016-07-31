//
//  PokestopAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokestopAnnotation.h"

@implementation PokestopAnnotation

- (instancetype)initWithPokestop:(PokeStop *)pokeStop
{
    if (self = [super init]) {
        self.coordinate = pokeStop.location;
        self.title      = NSLocalizedString(@"Pokestop", @"The title of a Pokéstop annotation on the map.");
        self.subtitle   = NSLocalizedString(@"This is a pokestop", @"The message of a Pokéstop annotation on the map.");
        self.pokestopID = pokeStop.identifier;
        self.hasLure = pokeStop.lureExpiration != nil;
    }
    return self;
}





@end
