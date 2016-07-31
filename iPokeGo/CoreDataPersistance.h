//
//  CoreDataPersistance.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

@import CoreData;
#import <Foundation/Foundation.h>

@interface CoreDataPersistance : NSObject

+ (instancetype)sharedInstance;
- (BOOL)commitChangesAndDiscardContext:(NSManagedObjectContext *)context;
- (BOOL)commitChangesToContext:(NSManagedObjectContext *)context;
- (void)discardConext:(NSManagedObjectContext *)context;
- (NSManagedObjectContext *)uiContext;
- (NSManagedObjectContext *)newWorkerContext;

@end
