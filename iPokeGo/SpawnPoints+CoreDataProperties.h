//
//  SpawnPoints+CoreDataProperties.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SpawnPoints+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpawnPoints (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

NS_ASSUME_NONNULL_END
