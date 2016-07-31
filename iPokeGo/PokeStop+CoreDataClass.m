//
//  PokeStop+CoreDataClass.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokeStop+CoreDataClass.h"

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
    
    if (self.lureExpiration != nil && (values[@"lure_expiration"] == nil || [values[@"lure_expiration"] isEqual:[NSNull null]])) {
        self.lureExpiration = nil;
        
    } else if (values[@"lure_expiration"] != nil && ![values[@"lure_expiration"] isEqual:[NSNull null]]) {
        NSDate *lureExpiration = [NSDate dateWithTimeIntervalSince1970:[values[@"lure_expiration"] integerValue] / 1000];
        if (!self.lureExpiration || ![self.lureExpiration isEqualToDate:lureExpiration]) {
            self.lureExpiration = lureExpiration;
            //TODO this is update more often than I'd expect
        }
    }
    if (!self.latitude) {
        self.latitude = [((NSNumber *)values[@"latitude"]) doubleValue];
    }
    if (!self.longitude) {
        self.longitude = [((NSNumber *)values[@"longitude"]) doubleValue];
    }
}

@end
