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

- (void)setLocation:(CLLocationCoordinate2D)location withRadius:(int)radius
{
    NSURL *url = [self buildChangeLocationRequestURLWithLocation:location withRadius:radius];
    if (!url) {
        return;
    }
    NSMutableURLRequest *request = [self buildRequestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error reading server's data: %@", error);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode == 200 || httpResponse.statusCode == 204) {
                NSLog(@"Position changed !");
            }else{
                NSLog(@"Server returned non 200 or 204 code: %@", @(httpResponse.statusCode));
                NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Error changing pinned location, server responded: %@", dataStr);
            }
        }
    }];
    [task resume];
}

-(void)removeLocation:(CLLocationCoordinate2D)location
{
    NSURL *url = [self buildRemoveLocationRequestURLWithLocation:location];
    if (!url) {
        return;
    }
    NSLog(@"%@", url);
    NSMutableURLRequest *request = [self buildRequestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"DELETE"];
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode != 200 && httpResponse.statusCode != 204) {
                NSLog(@"Server returned non 200 or 204 code: %@", @(httpResponse.statusCode));
                return;
            }
        }
        
        if (error) {
            NSLog(@"Error reading server's data: %@", error);
            return;
        }
    }];
    [task resume];
}

-(void)fetchData
{
    NSURL *url = [self buildLoadDataRequestURL];
    if (!url) {
        return;
    }
    NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:[self buildRequestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
        [self processSpawnPointsFromJSON:jsonData[@"spawnpoints"] usingContext:context];
        [self processScanLocationsFromJSON:[jsonData[@"scan_locations"] allValues] usingContext:context];
        [[CoreDataPersistance sharedInstance] commitChangesAndDiscardContext:context];
    }];
    [task resume];
}


-(void)fetchScanLocationData
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"server_type"] isEqualToString:SERVER_API_DATA_POKEMONGOMAP]) {
        NSURL *url = [self buildScanLocationRequestURL];
        
        NSURLSessionDataTask *task = [[iPokeServerSync sharedSession] dataTaskWithRequest:[self buildRequestWithURL:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode != 200) {
                    NSLog(@"Server returned non 200 code: %@", @(httpResponse.statusCode));
                    return;
                }
            }
            
            if (error) {
                NSLog(@"Error reading server's location data: %@", error);
                return;
            }
            
            NSDictionary *jsonData = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers
                                      error:&error];
            
            if (!jsonData || error) {
                NSLog(@"Error processing server's location data: %@", error);
                return;
            }
            NSLog(@"Fetched scan location data");
            
            // Transform location data
            NSNumber *latitude = [jsonData valueForKey:@"lat"];
            NSNumber *longitude = [jsonData valueForKey:@"lng"];
            NSString *idLocation = [[NSString alloc] initWithFormat:@"%@,%@", latitude, longitude];
            NSDictionary *dataLocation = [[NSDictionary alloc]
                                          initWithObjects:@[latitude, longitude, idLocation, @1, @1]
                                          forKeys:@[@"latitude", @"longitude", @"location", @"altitude", @"radius"]];
            NSArray *dataLocations = [[NSArray alloc] initWithObjects:dataLocation, nil];
            
            NSManagedObjectContext *context = [[CoreDataPersistance sharedInstance] newWorkerContext];
            [self processScanLocationsFromJSON:dataLocations usingContext:context];
            [[CoreDataPersistance sharedInstance] commitChangesAndDiscardContext:context];
        }];
        [task resume];
        NSLog(@"End process scan location data");
    }
}

-(NSURL *)buildLoadDataRequestURL
{
    // Build Request
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    BOOL display_pokemons           = [defaults boolForKey:@"display_pokemons"];
    BOOL display_pokestops          = [defaults boolForKey:@"display_pokestops"];
    BOOL display_gyms               = [defaults boolForKey:@"display_gyms"];
    BOOL display_spawnpoints        = [defaults boolForKey:@"display_spawnpoints"];
    NSString *request               = [defaults valueForKey:@"server_type"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    NSString *display_pokemons_str      = display_pokemons ? @"true" : @"false";
    NSString *display_pokestops_str     = display_pokestops ? @"true" : @"false";
    NSString *display_gyms_str          = display_gyms ? @"true" : @"false";
    NSString *display_spawnpoints_str   = display_spawnpoints ? @"true" : @"false";
    
    request = [request stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    request = [request stringByReplacingOccurrencesOfString:@"%%pokemon_display%%" withString:display_pokemons_str];
    request = [request stringByReplacingOccurrencesOfString:@"%%pokestops_display%%" withString:display_pokestops_str];
    request = [request stringByReplacingOccurrencesOfString:@"%%gyms_display%%" withString:display_gyms_str];
    request = [request stringByReplacingOccurrencesOfString:@"%%spawnpoints_display%%" withString:display_spawnpoints_str];
    
    //NSLog(@"%@", request);
    
    return [NSURL URLWithString:request];
}


-(NSURL *)buildScanLocationRequestURL
{
    // Build Request
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    NSString *request               = SERVER_API_DATA_SCAN_LOCATION;
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    request = [request stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    
    return [NSURL URLWithString:request];
}

- (NSURL *)buildChangeLocationRequestURLWithLocation:(CLLocationCoordinate2D)location withRadius:(int)radius
{
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    NSString *server_type           = [defaults objectForKey:@"server_type"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    NSString *request = nil;
    if ([server_type isEqualToString:SERVER_API_DATA_POGOM])
    {
        request = [SERVER_API_LOCA_POGOM stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
        request  = [request stringByReplacingOccurrencesOfString:@"%%latitude%%" withString:[NSString stringWithFormat:@"%f", location.latitude]];
        request  = [request stringByReplacingOccurrencesOfString:@"%%longitude%%" withString:[NSString stringWithFormat:@"%f", location.longitude]];
        request  = [request stringByReplacingOccurrencesOfString:@"%%radius%%" withString:[NSString stringWithFormat:@"%d", radius]];
    }
    else
    {
        request = [SERVER_API_LOCA_POKEMONGOMAP stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
        request  = [request stringByReplacingOccurrencesOfString:@"%%latitude%%" withString:[NSString stringWithFormat:@"%f", location.latitude]];
        request  = [request stringByReplacingOccurrencesOfString:@"%%longitude%%" withString:[NSString stringWithFormat:@"%f", location.longitude]];
    }
    
    return [NSURL URLWithString:request];
}

- (NSURL *)buildRemoveLocationRequestURLWithLocation:(CLLocationCoordinate2D)location
{
    // Only for pogom server
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    
    if([server_addr length] == 0) {
        return nil;
    }
    
    NSString *request = [SERVER_API_LOCAREMOVE_POGOM stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    request  = [request stringByReplacingOccurrencesOfString:@"%%latitude%%" withString:[NSString stringWithFormat:@"%f", location.latitude]];
    request  = [request stringByReplacingOccurrencesOfString:@"%%longitude%%" withString:[NSString stringWithFormat:@"%f", location.longitude]];
    
    return [NSURL URLWithString:request];
}

- (NSMutableURLRequest *)buildRequestWithURL:(NSURL *)url
{
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
	NSString *server_user           = [defaults objectForKey:@"server_user"];
	NSString *server_pass           = [defaults objectForKey:@"server_pass"];
	
	if (server_user.length > 0 || server_pass.length > 0) {
		NSString *authStr = [NSString stringWithFormat:@"%@:%@", server_user, server_pass];
		NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
		
		[request setValue:authValue forHTTPHeaderField:@"Authorization"];
	}
	
	return request;
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
    
    //we can shortcut and save processing in the background with pokemon since they can't be updated, only added / removed
    //only look for new pokemon
    NSFetchRequest *knownIDsRequest = [[NSFetchRequest alloc] init];
    [knownIDsRequest setEntity:entity];
    [knownIDsRequest setResultType:NSDictionaryResultType];
    [knownIDsRequest setReturnsDistinctResults:YES];
    [knownIDsRequest setPropertiesToFetch:@[@"spawnpoint"]];
    NSArray *knownPokemonIDs = [[context executeFetchRequest:knownIDsRequest error:nil] valueForKey:@"spawnpoint"];
    
    NSArray *newPokemon = [rawPokemon filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (spawnpoint_id IN %@)" argumentArray:@[knownPokemonIDs]]];
    for (NSDictionary *rawValues in newPokemon) {
        // if current entry is already expired, do not add again
        NSTimeInterval disappearsTimeInterval = [rawValues[@"disappear_time"] doubleValue] / 1000.0;
        NSDate *disappearsTime = [NSDate dateWithTimeIntervalSince1970:disappearsTimeInterval];
        if (disappearsTime < [NSDate date]) {
            NSLog(@"Skipped adding pokemon with disappear_time of %@", disappearsTime);
            continue;
        }

        Pokemon *pokemon = [[Pokemon alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
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

- (void)processSpawnPointsFromJSON:(NSArray *)rawSpawnPoints usingContext:(NSManagedObjectContext *)context
{
    if (!rawSpawnPoints) {
        return;
    }
    
    NSString *entityName = NSStringFromClass(SpawnPoints.class);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString *serverPrimaryKey = @"spawnpoint_id";
    NSArray *foundIdentifiers = [rawSpawnPoints valueForKey:serverPrimaryKey];
    if (!foundIdentifiers) {
        foundIdentifiers = @[];
    }
    
    NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
    [itemsToDeleteRequest setEntity:entity];
    [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[foundIdentifiers]]];
    [itemsToDeleteRequest setIncludesPropertyValues:NO];
    NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
    if (itemsToDelete.count > 0) {
        NSLog(@"Deleting %@ spawnpoints", @(itemsToDelete.count));
    }
    for (NSManagedObject *itemToDelete in itemsToDelete) {
        [context deleteObject:itemToDelete];
    }
    
    NSFetchRequest *knownItemsRequest = [[NSFetchRequest alloc] init];
    [knownItemsRequest setEntity:[NSEntityDescription  entityForName:entityName inManagedObjectContext:context]];
    NSArray *knownItems = [context executeFetchRequest:knownItemsRequest error:nil];
    
    for (NSDictionary *rawValues in rawSpawnPoints) {
        SpawnPoints *spawnpoint = [[knownItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@" argumentArray:@[rawValues[serverPrimaryKey]]]] firstObject];
        if (!spawnpoint) {
            spawnpoint = [[SpawnPoints alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        
        [spawnpoint syncToValues:rawValues];
    }
}

- (void)processScanLocationsFromJSON:(NSArray *)rawScanLocations usingContext:(NSManagedObjectContext *)context
{
    if (!rawScanLocations) {
        return;
    }
    
    NSString *entityName = NSStringFromClass(ScanLocations.class);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSString *serverPrimaryKey = @"location";
    NSArray *foundIdentifiers = [rawScanLocations valueForKey:serverPrimaryKey];
    if (!foundIdentifiers) {
        foundIdentifiers = @[];
    }
    
    NSFetchRequest *itemsToDeleteRequest = [[NSFetchRequest alloc] init];
    [itemsToDeleteRequest setEntity:entity];
    [itemsToDeleteRequest setPredicate:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[foundIdentifiers]]];
    [itemsToDeleteRequest setIncludesPropertyValues:NO];
    NSArray *itemsToDelete = [context executeFetchRequest:itemsToDeleteRequest error:nil];
    if (itemsToDelete.count > 0) {
        NSLog(@"Deleting %@ scanlocation", @(itemsToDelete.count));
    }
    for (NSManagedObject *itemToDelete in itemsToDelete) {
        [context deleteObject:itemToDelete];
    }
    
    NSFetchRequest *knownItemsRequest = [[NSFetchRequest alloc] init];
    [knownItemsRequest setEntity:[NSEntityDescription  entityForName:entityName inManagedObjectContext:context]];
    NSArray *knownItems = [context executeFetchRequest:knownItemsRequest error:nil];
    
    for (NSDictionary *rawValues in rawScanLocations) {
        ScanLocations *scanlocation = [[knownItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@" argumentArray:@[rawValues[serverPrimaryKey]]]] firstObject];
        if (!scanlocation) {
            scanlocation = [[ScanLocations alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        
        [scanlocation syncToValues:rawValues];
    }
}

@end
