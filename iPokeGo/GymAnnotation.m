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
    }
    return self;
}

@end
