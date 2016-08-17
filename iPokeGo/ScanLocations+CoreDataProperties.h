//
//  ScanLocations+CoreDataProperties.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 17/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ScanLocations+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScanLocations (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *identifier;
@property (nonatomic) int32_t altitude;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int32_t radius;

@end

NS_ASSUME_NONNULL_END
