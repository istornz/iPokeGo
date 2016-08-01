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
        
        // Expiration time is calculed by adding expiration time
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSDate *now = [NSDate date];
            
            NSDate *lureModified = [NSDate dateWithTimeIntervalSince1970:[values[@"last_modified"] doubleValue] / 1000.0];
            NSTimeInterval time_until_expire = [now timeIntervalSinceDate:lureModified];
            
            NSDate *lureExpiration = [now dateByAddingTimeInterval:time_until_expire];
            
            if (!self.lureExpiration || ![self.lureExpiration isEqualToDate:lureExpiration]) {
                self.lureExpiration = lureExpiration;
            }
        });
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
