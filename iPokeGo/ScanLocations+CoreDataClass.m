//
//  ScanLocations.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 17/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "ScanLocations+CoreDataClass.h"

@implementation ScanLocations

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (void)syncToValues:(NSDictionary *)values
{
    //this one can only be set on intial creation
    if (!self.identifier) {
        self.identifier = values[@"location"];
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
    if (!self.altitude) {
        self.altitude = [((NSNumber *)values[@"altitude"]) intValue];
    }
    if (!self.radius) {
        self.radius = [((NSNumber *)values[@"radius"]) intValue];
    }
}

@end
