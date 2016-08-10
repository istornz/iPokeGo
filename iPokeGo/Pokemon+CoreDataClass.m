//
//  Pokemon+CoreDataClass.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Pokemon+CoreDataClass.h"

@implementation Pokemon

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)syncToValues:(NSDictionary *)values
{
    if (self.identifier == 0) {
        self.identifier = [values[@"pokemon_id"] intValue];
    }
    NSTimeInterval disappearsTime = [values[@"disappear_time"] doubleValue] / 1000.0;
    if (!self.disappears || self.disappears.timeIntervalSince1970 != disappearsTime) {
        self.disappears = [NSDate dateWithTimeIntervalSince1970:disappearsTime];
    }
    //we don't want to ever be able to update this, only create
    if (!self.encounter) {
        self.encounter = values[@"encounter_id"];
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
    if (!self.name) {
        self.name = values[@"pokemon_name"];
    }
    if (!self.spawnpoint) {
        self.spawnpoint = values[@"spawnpoint_id"];
    }
    if (!self.rarity) {
        self.rarity = values[@"pokemon_rarity"];
    }
}

- (BOOL)isFav
{
    NSString *pokemonID = [NSString stringWithFormat:@"%@", @(self.identifier)];
    NSArray *favPokemon = [[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_favorite"];
    return [favPokemon containsObject:pokemonID];
}

- (BOOL)isCommon
{
    NSString *pokemonID = [NSString stringWithFormat:@"%@", @(self.identifier)];
    NSArray *commonPokemon = [[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_common"];
    return [commonPokemon containsObject:pokemonID];
}

@end
