//
//  PokemonAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotation.h"

@implementation PokemonAnnotation

- (instancetype)initWithPokemon:(Pokemon *)pokemon andLocalization:(NSDictionary *)localization
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });
    
    if (self = [super init]) {
        self.spawnpointID        = pokemon.spawnpoint;
        self.expirationDate      = pokemon.disappears;
        self.rarity              = pokemon.rarity;
        self.individual_attack   = pokemon.individual_attack;
        self.individual_defense  = pokemon.individual_defense;
        self.individual_stamina  = pokemon.individual_stamina;
        self.move_1              = pokemon.move_1;
        self.move_2              = pokemon.move_2;
        self.coordinate          = pokemon.location;
        self.title               = [localization objectForKey:[NSString stringWithFormat:@"%@", @(pokemon.identifier)]];
        self.iv                  = pokemon.iv;
        self.pokemonID           = pokemon.identifier;
        
        NSString *subtitleStr;
        if(self.iv > 0)
            subtitleStr = [NSString stringWithFormat:@"Atk: %d | Def: %d | Stm: %d", pokemon.individual_attack, pokemon.individual_defense, pokemon.individual_stamina];
        else
            subtitleStr = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."), [formatter stringFromDate:pokemon.disappears]];
        
        self.subtitle = subtitleStr;
        
    }
    return self;
}

@end
