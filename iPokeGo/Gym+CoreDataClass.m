//
//  Gym+CoreDataClass.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Gym+CoreDataClass.h"

@implementation Gym

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)syncToValues:(NSDictionary *)values
{
    //this one can only be set on intial creation
    if (!self.identifier) {
        self.identifier = values[@"gym_id"];
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
    if (self.team != [((NSNumber *)values[@"team_id"]) integerValue]) {
        self.team = [((NSNumber *)values[@"team_id"]) integerValue];
    }
    if (self.points != [((NSNumber *)values[@"gym_points"]) intValue]) {
        self.points = [((NSNumber *)values[@"gym_points"]) intValue];
    }
    
    if(values[@"guard_pokemon_id"] != [NSNull null])
    {
        if (self.guardingPokemonIdentifier != [((NSNumber *)values[@"guard_pokemon_id"]) intValue]) {
            self.guardingPokemonIdentifier = [((NSNumber *)values[@"guard_pokemon_id"]) intValue];
        }
    }
    
}

@end
