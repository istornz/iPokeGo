//
//  iPokeServerSync.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface iPokeServerSync : NSObject

- (void)fetchData;
- (void)fetchScanLocationData;
- (void)setLocation:(CLLocationCoordinate2D)location withRadius:(int)radius;
- (void)removeLocation:(CLLocationCoordinate2D)location;

@end
