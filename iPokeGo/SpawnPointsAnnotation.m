//
//  SpawnPoints.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SpawnPointsAnnotation.h"

@implementation SpawnPointsAnnotation

- (instancetype)initWithSpawnPoints:(SpawnPoints *)spawnPoint
{
    if (self = [super init]) {
        self.coordinate     = spawnPoint.location;
        self.title          = spawnPoint.identifier;
        self.spawnpointID   = spawnPoint.identifier;
    }
    return self;
}

@end
