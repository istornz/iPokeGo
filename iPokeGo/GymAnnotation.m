//
//  GymAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "GymAnnotation.h"

@implementation GymAnnotation

- (instancetype)initWithGym:(Gym *)gym
{
    if (self = [super init]) {
        self.coordinate     = gym.location;
        self.title          = NSLocalizedString(@"Gym", @"The title of a gym annotation on the map.");
        self.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Gym points: %d", @"The description of a gym annotation on the map with points."), gym.points];
        self.teamID         = gym.team;
        self.guardPokemonID = gym.guardingPokemonIdentifier;
        self.gymPoints      = gym.points;
        self.gymID          = gym.identifier;
        
        NSArray *gymLvl = @[@2000, @4000, @8000, @12000, @16000, @20000, @30000, @40000, @50000, @100000];
        int gym_level = 1;
        while (gym.points >= [gymLvl[gym_level - 1] integerValue]) {
            gym_level++;
        }
        
        self.gymLvl = gym_level;
    }
    return self;
}

@end
