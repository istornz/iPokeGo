//
//  PokeStop+CoreDataProperties.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokeStop+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface PokeStop (CoreDataProperties)

+ (NSFetchRequest<PokeStop *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSDate *lureExpiration;

@end

NS_ASSUME_NONNULL_END
