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
        self.pokestopID = pokeStop.identifier;
        self.hasLure    = pokeStop.lureExpiration != nil;
        
        if(self.hasLure)
            self.subtitle   = [NSString localizedStringWithFormat:NSLocalizedString(@"Lure expires at %@", @"The hint in a annotation callout that indicates when a Pokémon disappears."),
                               [NSDateFormatter localizedStringFromDate:pokeStop.lureExpiration dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]];
        else
            self.subtitle   = [NSString localizedStringWithFormat:NSLocalizedString(@"This is a pokestop", @"The hint in a annotation callout that indicates when the lure disappears."), [NSDateFormatter localizedStringFromDate:pokeStop.lureExpiration dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]];
    }
    return self;
}





@end
