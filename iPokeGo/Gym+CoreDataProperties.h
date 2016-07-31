//
//  Gym+CoreDataProperties.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Gym+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Gym (CoreDataProperties)

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) int16_t team;
@property (nonatomic) int32_t points;
@property (nonatomic) int32_t guardingPokemonIdentifier;

@end

NS_ASSUME_NONNULL_END
