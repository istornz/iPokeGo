//
//  SpawnPoints.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SpawnPoints+CoreDataClass.h"

@implementation SpawnPoints

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)syncToValues:(NSDictionary *)values
{
    //this one can only be set on intial creation
    if (!self.identifier) {
        self.identifier = values[@"spawnpoint_id"];
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
    
}

@end
