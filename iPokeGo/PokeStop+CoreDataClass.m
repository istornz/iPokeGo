//
//  PokeStop+CoreDataClass.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokeStop+CoreDataClass.h"
#import "PokeStop+CoreDataProperties.h"

@implementation PokeStop

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)syncToValues:(NSDictionary *)values
{
    //this one can only be set on intial creation
    if (!self.identifier) {
        self.identifier = values[@"pokestop_id"];
    }
    
    if (self.lureExpiration != nil && (id)values[@"lure_expiration"] == [NSNull null]) {
        self.lureExpiration = nil;
        
    } else if ((id)values[@"lure_expiration"] != [NSNull null]) {
        // TODO: Wait for a new value inside the API. "lure_expiration" isn't the real time
        NSNumber *expiration = values[@"lure_expiration"];
        NSDate *exirationDate = [NSDate dateWithTimeIntervalSince1970:[expiration doubleValue] / 1000.0];
        if (!self.lureExpiration || ![self.lureExpiration isEqualToDate:exirationDate]) {
            self.lureExpiration = exirationDate;
        }
    }
    
    if (self.luredPokemonID != 0 && (id)values[@"active_pokemon_id"] == [NSNull null]) {
        self.luredPokemonID = 0;
        
    } else if ((id)values[@"active_pokemon_id"] != [NSNull null]) {
        self.luredPokemonID = [((NSNumber *)values[@"active_pokemon_id"]) intValue];
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
}

@end
