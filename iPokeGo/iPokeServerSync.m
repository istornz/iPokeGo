//
//  iPokeServerSync.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

@import CoreData;
#import "CoreDataEntities.h"
#import "CoreDataPersistance.h"
#import "global.h"
#import "MapViewController.h"
#import "iPokeServerSync.h"

@implementation iPokeServerSync

static NSURLSession *iPokeServerSyncSharedSession;

+ (NSURLSession *)sharedSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setAllowsCellularAccess:YES];
        [sessionConfiguration setRequestCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
        [sessionConfiguration setHTTPCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
        [sessionConfiguration setHTTPAdditionalHeaders:@{ @"Accept" : @"application/json"}];
        iPokeServerSyncSharedSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    });
    
    return iPokeServerSyncSharedSession;
}

- (void)setLocation:(CLLocationCoordinate2D)location
{
    NSURL *url = [self buildChangeLocationRequestURLWithLocation:location];
    if (!url) {
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode != 200) {
                NSLog(@"Server returned non 200 code: %@", @(httpResponse.statusCode));
                return;
            }
        }
        
        if (error) {
            NSLog(@"Error reading server's data: %@", error);
            return;
        }
        
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if([dataStr isEqualToString:@"ok"]) {
            NSLog(@"Position changed !");
        } else {
            NSLog(@"Error changing pinned location, server responded: %@", dataStr);
        }
    }];
    [task resume];
}

- (void)setSearchControl:(NSString*)searchControlValue
{
    NSURL *url = [self buildSearchControlURLWithValue:searchControlValue];
    if (!url) {
        return;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            NSLog(@"Error reading server's data: %@", error);
            return;
        }
        if (data != nil) {
            NSError* err2 = nil;
            NSDictionary* dataStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err2];
            if (dataStr != nil && dataStr[@"status"] != nil) {
                NSLog(@"Search control changed to %@ !",searchControlValue);
            }
        } else {
            NSLog(@"Error changing search control, server returned with nil data");
        }
    }];
    [task resume];
}

- (void)callSearchControlValue {
    
    NSURL *url = [self buildSearchControlURLWithValue:@""];
    if (!url) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        BOOL switchedOn = NO;
        
        if (error) {
            NSLog(@"Search control GET, Error reading server's data: %@", error);
        }
        
        if (data != nil) {
            NSError* err2 = nil;
            NSDictionary* dataStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err2];
            if (dataStr != nil && dataStr[@"status"] != nil) {
                BOOL statusB = [dataStr[@"status"] boolValue];
                NSLog(@"Search control refreshed, read as %@ !",dataStr[@"status"]);
                switchedOn = statusB;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SERVER_SEARCH_STAT object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:switchedOn] forKey:@"val"]];
        });
    }];

    [task resume];
}

-(void)fetchData
{
    NSURL *url = [self buildLoadDataRequestURL];
    if (!url) {
        return;
    }
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode != 200) {
                NSLog(@"Server returned non 200 code: %@", @(httpResponse.statusCode));
                return;
            }
        }
        
        if (error) {
            NSLog(@"Error reading server's data: %@", error);
            return;
        }
        
        NSDictionary *jsonData = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingMutableContainers
                                  error:&error];
        
        if (!jsonData || error) {
            NSLog(@"Error processing server's data: %@", error);
            return;
        }
        NSLog(@"Fetched data");
        NSManagedObjectContext *context = [[CoreDataPersistance sharedInstance] newWorkerContext];
        [self processPokemonFromJSON:jsonData[@"pokemons"] usingContext:context];
        [self processStopsFromJSON:jsonData[@"pokestops"] usingContext:context];
        [self processGymsFromJSON:jsonData[@"gyms"] usingContext:context];
        [[CoreDataPersistance sharedInstance] commitChangesAndDiscardContext:context];
    }];
    [task resume];
}

-(NSURL *)buildLoadDataRequestURL
{
    // Build Request
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    BOOL display_pokemons           = [defaults boolForKey:@"display_pokemons"];
    BOOL display_pokestops          = [defaults boolForKey:@"display_pokestops"];
    BOOL display_gyms               = [defaults boolForKey:@"display_gyms"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    NSString *request                = SERVER_API_DATA;
    NSString *display_pokemons_str   = display_pokemons ? @"true" : @"false";
    NSString *display_pokestops_str  = display_pokestops ? @"true" : @"false";
    NSString *display_gyms_str       = display_gyms ? @"true" : @"false";
    
    request = [request stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    request = [request stringByReplacingOccurrencesOfString:@"%%pokemon_display%%" withString:display_pokemons_str];
    request = [request stringByReplacingOccurrencesOfString:@"%%pokestops_display%%" withString:display_pokestops_str];
    request = [request stringByReplacingOccurrencesOfString:@"%%gyms_display%%" withString:display_gyms_str];
    
    //NSLog(@"%@", request);
    
    return [NSURL URLWithString:request];
}

- (NSURL *)buildChangeLocationRequestURLWithLocation:(CLLocationCoordinate2D)location
{
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    NSString *request = [SERVER_API_LOCA stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    request  = [request stringByReplacingOccurrencesOfString:@"%%latitude%%" withString:[NSString stringWithFormat:@"%f", location.latitude]];
    request  = [request stringByReplacingOccurrencesOfString:@"%%longitude%%" withString:[NSString stringWithFormat:@"%f", location.longitude]];
    
    return [NSURL URLWithString:request];
}

- (NSURL *)buildSearchControlURLWithValue:(NSString*)value
{
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    if([value isEqualToString:@""]) {
        NSString* requestGet = [SERVER_API_SEARCH_GET stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
        if (requestGet != nil) {
            return [NSURL URLWithString:requestGet];
        }
    }
    
    NSString* request = [[SERVER_API_SEARCH stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr] stringByReplacingOccurrencesOfString:@"%%value%%" withString:value];
    return [NSURL URLWithString:request];
}

#pragma mark - Sync to CoreData logic

- (void)processPokemonFromJSON:(NSArray *)rawPokemon usingContext:(NSManagedObjectContext *)context
{
    if (!rawPokemon) {
        return;
    }
    
    NSString *entityName = NSStringFromClass(Pokemon.class);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString *serverPrimaryKey = @"spawnpoint_id";
    NSArray *foundIdentifiers = [rawPokemon valueForKey:serverPrimaryKey];
    if (!foundIdentifiers) {
        foundIdentifiers = @[];
    }
    
    NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
    [itemsToDeleteRequest setEntity:entity];
    [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (spawnpoint IN %@)" argumentArray:@[foundIdentifiers]]];
    [itemsToDeleteRequest setIncludesPropertyValues:NO];
    NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
    if (itemsToDelete.count > 0) {
        NSLog(@"Deleting %@ pokemon", @(itemsToDelete.count));
    }
    for (NSManagedObject *itemToDelete in itemsToDelete) {
        [context deleteObject:itemToDelete];
    }
    
    NSFetchRequest *knownItemsRequest = [[NSFetchRequest alloc] init];
    [knownItemsRequest setEntity:[NSEntityDescription  entityForName:entityName inManagedObjectContext:context]];
    NSArray *knownItems = [context executeFetchRequest:knownItemsRequest error:nil];
    
    for (NSDictionary *rawValues in rawPokemon) {
        Pokemon *pokemon = [[knownItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"spawnpoint = %@" argumentArray:@[rawValues[serverPrimaryKey]]]] firstObject];
        if (!pokemon) {
            pokemon = [[Pokemon alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        [pokemon syncToValues:rawValues];
    }
}

- (void)processStopsFromJSON:(NSArray *)rawStops usingContext:(NSManagedObjectContext *)context
{
    if (!rawStops) {
        return;
    }
    
    NSString *entityName = NSStringFromClass(PokeStop.class);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString *serverPrimaryKey = @"pokestop_id";
    NSArray *foundIdentifiers = [rawStops valueForKey:serverPrimaryKey];
    if (!foundIdentifiers) {
        foundIdentifiers = @[];
    }
    
    NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
    [itemsToDeleteRequest setEntity:entity];
    [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[foundIdentifiers]]];
    [itemsToDeleteRequest setIncludesPropertyValues:NO];
    NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
    if (itemsToDelete.count > 0) {
        NSLog(@"Deleting %@ pokemon", @(itemsToDelete.count));
    }
    for (NSManagedObject *itemToDelete in itemsToDelete) {
        [context deleteObject:itemToDelete];
    }
    
    NSFetchRequest *knownItemsRequest = [[NSFetchRequest alloc] init];
    [knownItemsRequest setEntity:[NSEntityDescription  entityForName:entityName inManagedObjectContext:context]];
    NSArray *knownItems = [context executeFetchRequest:knownItemsRequest error:nil];
    
    for (NSDictionary *rawValues in rawStops) {
        PokeStop *pokestop = [[knownItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@" argumentArray:@[rawValues[serverPrimaryKey]]]] firstObject];
        if (!pokestop) {
            pokestop = [[PokeStop alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        [pokestop syncToValues:rawValues];
    }
}

- (void)processGymsFromJSON:(NSArray *)rawGyms usingContext:(NSManagedObjectContext *)context
{
    if (!rawGyms) {
        return;
    }
    
    NSString *entityName = NSStringFromClass(Gym.class);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString *serverPrimaryKey = @"gym_id";
    NSArray *foundIdentifiers = [rawGyms valueForKey:serverPrimaryKey];
    if (!foundIdentifiers) {
        foundIdentifiers = @[];
    }
    
    NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
    [itemsToDeleteRequest setEntity:entity];
    [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[foundIdentifiers]]];
    [itemsToDeleteRequest setIncludesPropertyValues:NO];
    NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
    if (itemsToDelete.count > 0) {
        NSLog(@"Deleting %@ gyms", @(itemsToDelete.count));
    }
    for (NSManagedObject *itemToDelete in itemsToDelete) {
        [context deleteObject:itemToDelete];
    }
    
    NSFetchRequest *knownItemsRequest = [[NSFetchRequest alloc] init];
    [knownItemsRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
    NSArray *knownItems = [context executeFetchRequest:knownItemsRequest error:nil];
    
    for (NSDictionary *rawValues in rawGyms) {
        Gym *gym = [[knownItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@" argumentArray:@[rawValues[serverPrimaryKey]]]] firstObject];
        if (!gym) {
            gym = [[Gym alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        [gym syncToValues:rawValues];
    }
}

@end
