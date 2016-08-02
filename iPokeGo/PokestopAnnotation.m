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
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });
    
    if (self = [super init]) {
        self.coordinate = pokeStop.location;
        self.title      = NSLocalizedString(@"Pokestop", @"The title of a Pokéstop annotation on the map.");
        self.pokestopID = pokeStop.identifier;
        self.hasLure    = ((pokeStop.lureExpiration != nil) && ([pokeStop.lureExpiration timeIntervalSinceNow] > 0.0));
        self.luredPokemonID = (self.hasLure && pokeStop.luredPokemonID > 0) ? pokeStop.luredPokemonID : 0;
        
        if(self.hasLure) {
            self.subtitle   = [NSString localizedStringWithFormat:NSLocalizedString(@"Lure expires at %@", @"The hint in a annotation callout that indicates when a Pokémon disappears."),
                               [formatter stringFromDate:pokeStop.lureExpiration]];
        } else {
            self.subtitle   = nil;
        }
    }
    return self;
}


@end
