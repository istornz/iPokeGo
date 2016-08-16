//
//  SpawnPoints.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import CoreLocation;

NS_ASSUME_NONNULL_BEGIN

@interface SpawnPoints : NSManagedObject

@property (readonly) CLLocationCoordinate2D location;
- (void)syncToValues:(NSDictionary *)values;

@end

NS_ASSUME_NONNULL_END

#import "SpawnPoints+CoreDataProperties.h"
