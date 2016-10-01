//
//  Pokemon+CoreDataProperties.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Pokemon+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Pokemon (CoreDataProperties)

@property (nullable, nonatomic, copy) NSDate *disappears;
@property (nullable, nonatomic, copy) NSString *encounter;
@property (nonatomic) int32_t identifier;
@property (nonatomic) int16_t individual_attack;
@property (nonatomic) int16_t individual_defense;
@property (nonatomic) int16_t individual_stamina;
@property (nonatomic) int16_t move_1;
@property (nonatomic) int16_t move_2;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *spawnpoint;
@property (nullable, nonatomic, copy) NSString *rarity;

@end

NS_ASSUME_NONNULL_END
