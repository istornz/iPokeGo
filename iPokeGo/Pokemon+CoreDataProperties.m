//
//  Pokemon+CoreDataProperties.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Pokemon+CoreDataProperties.h"

@implementation Pokemon (CoreDataProperties)

+ (NSFetchRequest<Pokemon *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Pokemon"];
}

@dynamic disappears;
@dynamic encounter;
@dynamic identifier;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic spawnpoint;

@end
