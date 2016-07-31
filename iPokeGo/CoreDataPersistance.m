//
//  CoreDataPersistance.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "CoreDataPersistance.h"

@interface CoreDataPersistance()

@property NSManagedObjectContext *mainContext;
@property NSManagedObjectContext *writeContext;
@property NSMutableArray<NSManagedObjectContext *> *workers;

@end

@implementation CoreDataPersistance

+ (instancetype)sharedInstance {
    static CoreDataPersistance *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CoreDataPersistance alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(mom != nil, @"Error initializing Managed Object Model");
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        self.writeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.writeContext.persistentStoreCoordinator = psc;
        self.writeContext.name = @"Write context";
        self.writeContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        self.mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.mainContext.persistentStoreCoordinator = psc;
        self.mainContext.name = @"UI context";
        self.mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainContextDidSaveNotificiation:) name:NSManagedObjectContextDidSaveNotification object:self.mainContext];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Data.sqlite"];
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption : @YES} error:&error];
        if (!store) {
            //if the store can't use a lightweight migration the above fails. since we don't persist user data in the store
            //we can just blow it away and start fresh if there is an error like this
            NSLog(@"Removing old persistant store");
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption : @YES} error:&error];
            NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
        self.workers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)commitChangesAndDiscardContext:(NSManagedObjectContext *)context
{
    if (![self commitChangesToContext:context]) {
        return NO;
    }
    
    [self discardConext:context];
    
    return YES;
}

- (BOOL)commitChangesToContext:(NSManagedObjectContext *)context
{
    __block BOOL success = YES;
    if (!context.hasChanges) {
        return success;
    }
    
    [context performBlockAndWait:^{
        if (context.insertedObjects.count > 0) {
            NSError *error;
            if (![context obtainPermanentIDsForObjects:[context.insertedObjects allObjects] error:&error]) {
                NSLog(@"Error getting IDs for temp objects: %@", error);
            }
        }
        NSError *error;
        success = [context save:&error];
        if (!success) {
            NSLog(@"Error saving context: %@", error);
            return;
        }
        
        if (context.parentContext) {
            [context.parentContext performBlockAndWait:^{
                NSError *parentError;
                success = [context.parentContext save:&parentError];
                if (!success) {
                    NSLog(@"Error saving parent context: %@", error);
                    [context.parentContext rollback];
                }
            }];
        }
    }];
    
    return success;
}

- (void)discardConext:(NSManagedObjectContext *)context
{
    [self.workers removeObject:context];
}

- (NSManagedObjectContext *)uiContext
{
    return self.mainContext;
}

- (NSManagedObjectContext *)newWorkerContext
{
    NSManagedObjectContext *worker = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    worker.parentContext = self.mainContext;
    worker.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    [self.workers addObject:worker];
    
    return worker;
}

- (void)mainContextDidSaveNotificiation:(NSNotification *)notification
{
    [self.writeContext mergeChangesFromContextDidSaveNotification:notification];
}

@end
