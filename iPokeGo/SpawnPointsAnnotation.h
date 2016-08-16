//
//  SpawnPoints.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CoreDataEntities.h"

@interface SpawnPointsAnnotation : MKPointAnnotation

@property NSString *spawnpointID;
- (instancetype)initWithSpawnPoints:(SpawnPoints *)spawnpoint;

@end
