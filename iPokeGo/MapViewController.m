//
//  ViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "MapViewController.h"
#import "TimeLabel.h"
#import "TimerLabel.h"
#import "DistanceLabel.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.pokemons   = [[NSMutableArray alloc] init];
    self.pokestops  = [[NSMutableArray alloc] init];
    self.gyms       = [[NSMutableArray alloc] init];
    self.verycommon = [[NSMutableArray alloc] initWithObjects:@"13",
                                                                @"41",
                                                                @"19",
                                                                @"16",
                                                                @"96", nil];
    
    self.mapview.zoomEnabled = true;
    moved                           = NO;
    firstConnection                 = YES;
    isFav                           = NO;
    isNormalNotificationActivated   = YES;
    isFavNotificationActivated      = YES;
    isHideVeryCommonActivated       = NO;
    
    [self initObserver];
    [self loadSavedData];
    [self loadLocalization];
    [self checkGPS];
    [self loadSoundFiles];
    self.requestStr             = [self buildRequest];
    
    if(self.requestStr != nil)
    {
        [self launchTimers];
    }
    else
    {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Server not set"
                                    message:@"Please go in settings to enter server address"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self performSegueWithIdentifier:@"showSettings" sender:nil];
                             }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)launchTimers
{
    if(![self.timerData isValid])
    {
        NSLog(@"[+] Starting data timer...");
        self.timerData = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(loadData)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    if(![self.timerDataCleaner isValid])
    {
        NSLog(@"[+] Starting clear timer...");
        self.timerDataCleaner = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(mapCleaner)
                                                               userInfo:nil
                                                                repeats:YES];
    }
}

-(void)initObserver
{
    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                    selector:@selector(hideAnnotations)
                                    name:@"HideRefresh"
                                    object:nil];
    
    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                    selector:@selector(loadSavedData)
                                    name:@"LoadSaveData"
                                    object:nil];
    
    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                    selector:@selector(launchTimers)
                                    name:@"LaunchTimers"
                                    object:nil];
    
    [[NSNotificationCenter defaultCenter]
                                    addObserver:self
                                    selector:@selector(refreshPokemons)
                                    name:@"RefreshPokemons"
                                    object:nil];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapview addGestureRecognizer:longPressGesture];
}

#pragma mark Long gesture press

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        CGPoint point = [sender locationInView:self.mapview];
        CLLocationCoordinate2D locCoord = [self.mapview convertPoint:point toCoordinateFromView:self.mapview];
        
        ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
        radar = locCoord;
        
        [prefs setObject:[NSNumber numberWithDouble:locCoord.latitude] forKey:@"radar_lat"];
        [prefs setObject:[NSNumber numberWithDouble:locCoord.longitude] forKey:@"radar_long"];
        
        [prefs synchronize];
        
        dropPin.coordinate = locCoord;
        dropPin.title = @"Scan location";
        
        for (int i = 0; i < [self.mapview.annotations count]; i++) {
            MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
            
            if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                [self.mapview removeAnnotation:annotation];
        }
        
        [self sendNewLocationToServer:locCoord.latitude and:locCoord.longitude];
        [self.mapview addAnnotation:dropPin];
    }
}

-(void)sendNewLocationToServer:(CLLocationDegrees)latitude and:(CLLocationDegrees)longitude
{
    NSString *requestStr   = self.requestNewLocationStr;
    requestStr  = [self.requestNewLocationStr stringByReplacingOccurrencesOfString:@"%%latitude%%" withString:[NSString stringWithFormat:@"%f", latitude]];
    requestStr  = [requestStr stringByReplacingOccurrencesOfString:@"%%longitude%%" withString:[NSString stringWithFormat:@"%f", longitude]];
    
    /*************************************/
    //           Requête POST            //
    /*************************************/
#pragma mark Requête POST
    
    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    // Lancement de la requête
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                if (data != nil && error == nil && [httpResponse statusCode] == 200)
                                {
                                    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                    if([dataStr isEqualToString:@"ok"])
                                        NSLog(@"Position changed !");
                                }
                                else
                                {
                                    NSLog(@"Error %@", error);
                                }
                                   
                               }];

}

-(void)loadSavedData
{
    NSLog(@"[+] ----- LOAD SAVE DATA");
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    
    self.savedFavorite              = [defaults objectForKey:@"pokemon_favorite"];
    self.mapLocation                = [defaults objectForKey:@"map_position"];
    
    if([defaults objectForKey:@"norm_notification"] != nil)
        isNormalNotificationActivated   = [defaults boolForKey:@"norm_notification"];
    
    if([defaults objectForKey:@"fav_notification"] != nil)
        isFavNotificationActivated      = [defaults boolForKey:@"fav_notification"];
    
    if([defaults objectForKey:@"display_common"] != nil)
    {
        if(isHideVeryCommonActivated != [defaults boolForKey:@"display_common"])
        {
            isHideVeryCommonActivated       = [defaults boolForKey:@"display_common"];
            firstConnection                 = YES;
        }
    }
    
    if(([defaults objectForKey:@"radar_lat"] != nil) && ([defaults objectForKey:@"radar_long"] != nil))
    {
        for (int i = 0; i < [self.mapview.annotations count]; i++) {
            MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
            
            if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                [self.mapview removeAnnotation:annotation];
        }
        
        NSLog(@"[!] - Restore radar");
        CLLocationCoordinate2D locCoord;
        locCoord.latitude   = [defaults doubleForKey:@"radar_lat"];
        locCoord.longitude  = [defaults doubleForKey:@"radar_long"];
        
        ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
        radar = locCoord;
        
        dropPin.coordinate = locCoord;
        dropPin.title = @"Scan location";
        [self.mapview addAnnotation:dropPin];
    }
}

-(void)loadSoundFiles
{
    NSString *pathPokemonAppearSound    = [NSString stringWithFormat:@"%@/ding.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrlPokemonAppearSound   = [NSURL fileURLWithPath:pathPokemonAppearSound];
    
    NSString *pathPokemonFavAppearSound    = [NSString stringWithFormat:@"%@/favoritePokemon.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrlPokemonFavAppearSound   = [NSURL fileURLWithPath:pathPokemonFavAppearSound];
    
    pokemonAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonAppearSound error:nil];
    pokemonFavAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonFavAppearSound error:nil];
}

-(void)loadLocalization
{
    NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSError *error;
    
    NSURL *filePath = nil;
    
    self.localization = [[NSDictionary alloc] init];
    
    if([language isEqualToString:@"fr"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.fr" withExtension:@"json"];
    else if([language isEqualToString:@"de"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.de" withExtension:@"json"];
    else if([language isEqualToString:@"en"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.en" withExtension:@"json"];
    else if([language isEqualToString:@"zh_cn"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.zh_cn" withExtension:@"json"];
    else
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.en" withExtension:@"json"];
    
    NSString *stringPath = [filePath absoluteString];
    NSData *localizationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    self.localization = [NSJSONSerialization JSONObjectWithData:localizationData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSArray *annotations = [self.mapview annotations];
    MKPointAnnotation *annotation = nil;
    
    for (int i = 0; i < [annotations count]; i++)
    {
        annotation = (MKPointAnnotation *)[annotations objectAtIndex:i];
        if (self.mapview.region.span.latitudeDelta > .20)
        {
            if([annotation isKindOfClass:[PokemonAnnotation class]] || [annotation isKindOfClass:[GymAnnotation class]] || [annotation isKindOfClass:[PokestopAnnotation class]])
                [[self.mapview viewForAnnotation:annotation] setHidden:YES];
        }
        else
        {
            [[self.mapview viewForAnnotation:annotation] setHidden:NO];
        }
    }
    
    // Saving current position
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *mapRegion = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithDouble:self.mapview.region.center.latitude], [NSNumber numberWithDouble:self.mapview.region.center.longitude], [NSNumber numberWithDouble:self.mapview.region.span.latitudeDelta], [NSNumber numberWithDouble:self.mapview.region.span.longitudeDelta]] forKeys:@[@"latitude", @"longitude", @"latitudeDelta", @"longitudeDelta"]];
    
    [prefs setObject:mapRegion forKey:@"map_position"];
    [prefs synchronize];
}

-(void)checkGPS
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        //Location Services is off from settings
        UIAlertController *alert = [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Location denied, please go in settings to allow this app to use your location"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    if([self.mapLocation count] > 0)
    {
        region.center.latitude      = [[self.mapLocation objectForKey:@"latitude"] doubleValue];
        region.center.longitude     = [[self.mapLocation objectForKey:@"longitude"] doubleValue];
        region.span.latitudeDelta   = [[self.mapLocation objectForKey:@"latitudeDelta"] doubleValue];
        region.span.longitudeDelta  = [[self.mapLocation objectForKey:@"longitudeDelta"] doubleValue];
        
        moved = YES;
        [self.mapview setRegion:region animated:YES];
    }
    else
    {
        [self performSelector:@selector(locationAction:) withObject:nil afterDelay:0];
    }
}

-(void)loadData
{
    //Loading in background
    
    /*************************************/
    //            Requête GET            //
    /*************************************/
#pragma mark Requête GET
    
    NSURL *url = [NSURL URLWithString:self.requestStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    // Lancement de la requête
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               if (data != nil && error == nil && [httpResponse statusCode] == 200)
                               {
                                   NSDictionary *jsonData = [NSJSONSerialization
                                                             JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                             error:&error];
                                   
                                   if([self.display_pokemons_str isEqualToString:@"true"])
                                   {
                                       BOOL annFound = NO;
                                       self.pokemons = jsonData[@"pokemons"];
                                       
                                       if([self.pokemons count] > 0)
                                       {
                                           for (int i = 0; i < [self.pokemons count]; i++) {
                                               
                                               for (id<MKAnnotation> ann in self.mapview.annotations)
                                               {
                                                   annFound = NO;
                                                   if ([ann isKindOfClass:[PokemonAnnotation class]])
                                                   {
                                                       PokemonAnnotation *myAnn = (PokemonAnnotation *)ann;
                                                       if ((myAnn.coordinate.latitude == [self.pokemons[i][@"latitude"] floatValue]) && (myAnn.coordinate.longitude == [self.pokemons[i][@"longitude"] floatValue]))
                                                       {
                                                           annFound = YES;
                                                           break;
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   PokemonAnnotation *point = [[PokemonAnnotation alloc] init];
                                                   CLLocationCoordinate2D pokemonLocation = CLLocationCoordinate2DMake([self.pokemons[i][@"latitude"] floatValue], [self.pokemons[i][@"longitude"] floatValue]);

                                                   NSString *disapearTime = [self.pokemons[i] valueForKey:@"disappear_time"];
                                                   double milliTime = disapearTime.doubleValue;
                                                   
                                                   NSDate *date = [NSDate dateWithTimeIntervalSince1970:(milliTime / 1000)];
                                                   
                                                   NSCalendar *calendar = [NSCalendar currentCalendar];
                                                   NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
                                                   NSInteger hour   = [components hour];
                                                   NSInteger minute = [components minute];
                                                   NSInteger second = [components second];
                                                   
                                                   NSString *key    = [self.pokemons[i] objectForKey:@"pokemon_id"];
                                                   
                                                   BOOL isPokemonVeryCommonPokemon = [self isPokemonVeryCommon:[NSString stringWithFormat:@"%@", key]];
                                                   
                                                   if([date timeIntervalSinceNow] > 0.0)
                                                   {
                                                       if((isPokemonVeryCommonPokemon == YES) && (isHideVeryCommonActivated == YES))
                                                       {
                                                           // Nothing to do
                                                           // Option "hide very common" activated and the pokemon is very common
                                                       }
                                                       else
                                                       {
                                                           point.hidePokemon    = isPokemonVeryCommonPokemon;
                                                           point.spawnpointID   = [self.pokemons[i] objectForKey:@"spawnpoint_id"];
                                                           point.expirationDate = date;
                                                           
                                                           point.coordinate     = pokemonLocation;
                                                           point.title          = [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]];
                                                           point.subtitle       = [NSString stringWithFormat:@"Disappears at %02d:%02d:%02d", (int)hour, (int)minute, (int)second];
                                                           point.pokemonID      = [[self.pokemons[i] valueForKey:@"pokemon_id"] intValue];
                                                           
                                                           [self.mapview addAnnotation:point];
                                                           
                                                           if(!firstConnection)
                                                           {
                                                               NSString *notificationMessage = [NSString stringWithFormat:@"%@ was added on the map !", point.title];
                                                               if([self.savedFavorite count] > 0)
                                                               {
                                                                   isFav = NO;
                                                                   for (NSString *pokemonID in self.savedFavorite) {
                                                                       if ([pokemonID intValue] == [key intValue]) {
                                                                           isFav = YES;
                                                                           break;
                                                                       }
                                                                   }
                                                               }
                                                               
                                                               if(isFav)
                                                               {
                                                                   NSLog(@"FAV Pokemon added on map !!");
                                                                   
                                                                   notificationMessage = [NSString stringWithFormat:@"%@ your favorite pokemon was on the map !", point.title];
                                                                   
                                                                   if(isFavNotificationActivated)
                                                                   {
                                                                       self.notification = [CWStatusBarNotification new];
                                                                       self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];;
                                                                       self.notification.notificationLabelTextColor = [UIColor whiteColor];
                                                                       
                                                                       [pokemonFavAppearSound play];
                                                                       
                                                                       [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                       
                                                                       __weak typeof(self) weakSelf = self;
                                                                       self.notification.notificationTappedBlock = ^(void) {
                                                                           [weakSelf.mapview showAnnotations:@[point] animated:YES];
                                                                       };
                                                                   }
                                                               }
                                                               else
                                                               {
                                                                   NSLog(@"Pokemon added on map %@", point.title);
                                                                   if(isNormalNotificationActivated)
                                                                   {
                                                                       self.notification = [CWStatusBarNotification new];
                                                                       [pokemonAppearSound play];
                                                                       
                                                                       [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                       
                                                                       __weak typeof(self) weakSelf = self;
                                                                       self.notification.notificationTappedBlock = ^(void) {
                                                                           [weakSelf.mapview showAnnotations:@[point] animated:YES];
                                                                       };
                                                                   }
                                                               }
                                                               
                                                               
                                                           }
                                                       }
                                                       
                                                   }
                                               }
                                               
                                           }
                                       }
                                   }
                                   
                                   if([self.display_pokestops_str isEqualToString:@"true"])
                                   {
                                       BOOL annFound = NO;
                                       self.pokestops = jsonData[@"pokestops"];
                                       
                                       if([self.pokestops count] > 0)
                                       {
                                           for (int i = 0; i < [self.pokestops count]; i++) {
                                               
                                               for (id<MKAnnotation> ann in self.mapview.annotations)
                                               {
                                                   if ([ann isKindOfClass:[PokestopAnnotation class]])
                                                   {
                                                       PokestopAnnotation *myAnn = (PokestopAnnotation *)ann;
                                                       if ((myAnn.coordinate.latitude == [self.pokestops[i][@"latitude"] floatValue]) && (myAnn.coordinate.longitude == [self.pokestops[i][@"longitude"] floatValue]))
                                                       {
                                                           annFound = YES;
                                                           break;
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   PokestopAnnotation *point = [[PokestopAnnotation alloc] init];
                                                   CLLocationCoordinate2D pokestopLocation = CLLocationCoordinate2DMake([self.pokestops[i][@"latitude"] floatValue], [self.pokestops[i][@"longitude"] floatValue]);
                                                   
                                                   point.coordinate = pokestopLocation;
                                                   point.title      = @"Pokestop";
                                                   point.subtitle   = @"This is a pokestop";
                                                   point.pokestopID = [[self.pokestops[i] valueForKey:@"pokestop_id"] intValue];
                                                   
                                                   if([[self.pokestops[i] valueForKey:@"lure_expiration"] isKindOfClass:[NSNull class]])
                                                       point.lure       = @"none";
                                                   else
                                                       point.lure       = [self.pokestops[i] valueForKey:@"lure_expiration"];
                                                   
                                                   [self.mapview addAnnotation:point];
                                               }
                                           }
                                       }
                                   }
                                   
                                   if([self.display_gyms_str isEqualToString:@"true"])
                                   {
                                       BOOL annFound = NO;
                                       self.gyms = jsonData[@"gyms"];
                                       
                                       if([self.gyms count] > 0)
                                       {
                                           for (int i = 0; i < [self.gyms count]; i++) {
                                               
                                               for (id<MKAnnotation> ann in self.mapview.annotations)
                                               {
                                                   if ([ann isKindOfClass:[GymAnnotation class]])
                                                   {
                                                       GymAnnotation *myAnn = (GymAnnotation *)ann;
                                                       if ((myAnn.coordinate.latitude == [self.gyms[i][@"latitude"] floatValue]) && (myAnn.coordinate.longitude == [self.gyms[i][@"longitude"] floatValue]))
                                                       {
                                                           annFound = YES;
                                                           break;
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   GymAnnotation *point = [[GymAnnotation alloc] init];
                                                   CLLocationCoordinate2D gymLocation = CLLocationCoordinate2DMake([self.gyms[i][@"latitude"] floatValue], [self.gyms[i][@"longitude"] floatValue]);
                                                   
                                                   point.coordinate     = gymLocation;
                                                   point.title          = @"Gym";
                                                   point.subtitle       = [NSString stringWithFormat:@"Gym points : %d", [self.gyms[i][@"gym_points"] intValue]];
                                                   point.gymsID         = [[self.gyms[i] valueForKey:@"team_id"] intValue];
                                                   point.guardPokemonID = [[self.gyms[i] valueForKey:@"guard_pokemon_id"] intValue];
                                                   point.gym_points     = [[self.gyms[i] valueForKey:@"gym_points"] intValue];
                                                   
                                                   [self.mapview addAnnotation:point];
                                               }
                                           }
                                       }
                                   }
                                   
                                   firstConnection = NO;
                                   
                               }
                               else
                               {
                                   NSLog(@"Error %@", error);
                               }
                           }];
}
                                                  
-(NSString *)buildRequest
{
    // Build Request
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *server_addr           = [defaults objectForKey:@"server_addr"];
    BOOL display_pokemons           = [defaults boolForKey:@"display_pokemons"];
    BOOL display_pokestops          = [defaults boolForKey:@"display_pokestops"];
    BOOL display_gyms               = [defaults boolForKey:@"display_gyms"];
    
    NSString *request           = SERVER_API_DATA;
    self.requestNewLocationStr  = SERVER_API_LOCA;
    
    self.display_pokemons_str   = @"true";
    self.display_pokestops_str  = @"false";
    self.display_gyms_str       = @"true";
    
    if([server_addr length] > 0)
    {
        if([defaults objectForKey:@"display_pokemons"] != nil)
        {
            if(!display_pokemons)
                self.display_pokemons_str = @"false";
        }
        
        if([defaults objectForKey:@"display_pokestops"] != nil)
        {
            if(display_pokestops)
                self.display_pokestops_str = @"true";
        }
        
        if([defaults objectForKey:@"display_gyms"] != nil)
        {
            if(!display_gyms)
                self.display_gyms_str = @"false";
        }
        
        request = [request stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
        request = [request stringByReplacingOccurrencesOfString:@"%%pokemon_display%%" withString:self.display_pokemons_str];
        request = [request stringByReplacingOccurrencesOfString:@"%%pokestops_display%%" withString:self.display_pokestops_str];
        request = [request stringByReplacingOccurrencesOfString:@"%%gyms_display%%" withString:self.display_gyms_str];
        
        NSLog(@"%@", request);
        self.requestNewLocationStr = [self.requestNewLocationStr stringByReplacingOccurrencesOfString:@"%%server_addr%%" withString:server_addr];
    }
    else
    {
        request = nil;
    }
    
    return request;
}

-(BOOL)isPokemonVeryCommon:(NSString *)idPokeToTest
{
    BOOL returnState = NO;

    for (int i = 0; i < [self.verycommon count]; i++) {
        NSString *idTab = [self.verycommon objectAtIndex:i];
        
        if ([idPokeToTest isEqualToString:idTab])
        {
            returnState = YES;
            break;
        }
    }
    
    return returnState;
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *view = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ((id<MKAnnotation>)annotation != mapView.userLocation) {
        
        if([annotation isKindOfClass:[PokemonAnnotation class]])
        {
            PokemonAnnotation *annotationPokemon = annotation;
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%d",annotationPokemon.pokemonID]];
            
            if (!view) {
                
                UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *btnImage   = [UIImage imageNamed:@"drive"];
                button.frame = CGRectMake(0, 0, 30, 30);
                [button setImage:btnImage forState:UIControlStateNormal];
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%d",annotationPokemon.pokemonID]];
                view.canShowCallout = YES;
                view.rightCalloutAccessoryView = button;
                
                UIImage *largeImage = [UIImage imageNamed : @"icons-hd.png"];
                
                /* Spritesheet has 7 columns */
                int x = (annotationPokemon.pokemonID - 1)%SPRITESHEET_COLS*SPRITE_SIZE;
                
                int y = annotationPokemon.pokemonID;
                
                while(y%SPRITESHEET_COLS != 0) y++;
                
                y = (y/SPRITESHEET_COLS - 1) * SPRITE_SIZE;
                
                CGRect cropRect = CGRectMake(x, y, SPRITE_SIZE, SPRITE_SIZE);
                
                CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
                view.image = [UIImage imageWithCGImage:imageRef];
                
                view.frame = CGRectMake(0, 0, IMAGE_SIZE*1.5, IMAGE_SIZE*1.5);
                CGImageRelease(imageRef);
                
                if([defaults boolForKey:@"display_time"]) {
                    [view addSubview:[self timeLabelForAnnotation:annotationPokemon withContainerFrame:view.frame]];
                }
                
                if([defaults boolForKey:@"display_distance"]) {
                    [view addSubview:[self distanceLabelForAnnotation:annotationPokemon withContainerFrame:view.frame]];
                }
                
                
            } else {
                // TODO: Its just for 'live' view update when settings changed, probably need to optimise
                for (UIView *subView in view.subviews) {
                    if ([subView isKindOfClass:[TimeLabel class]]) {
                        [subView removeFromSuperview];
                    }
                    if ([subView isKindOfClass:[DistanceLabel class]]) {
                        [subView removeFromSuperview];
                    }
                }
                
                if([defaults boolForKey:@"display_time"]) {
                    [view addSubview:[self timeLabelForAnnotation:annotationPokemon withContainerFrame:view.frame]];
                }
                
                if([defaults boolForKey:@"display_distance"]) {
                    [view addSubview:[self distanceLabelForAnnotation:annotationPokemon withContainerFrame:view.frame]];
                }
            }
        }
        else if ([annotation isKindOfClass:[GymAnnotation class]])
        {
            GymAnnotation *annotationGym = annotation;
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%d",annotationGym.gymsID]];
            if (!view) {
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%d",annotationGym.gymsID]];
                view.canShowCallout = YES;
                UIImage *gymImage = [UIImage imageNamed:@"Gym.png"];
                
                switch (annotationGym.gymsID) {
                    case TEAM_BLUE:
                        gymImage = [UIImage imageNamed:@"Mystic.png"];
                        break;
                    case TEAM_RED:
                        gymImage = [UIImage imageNamed:@"Valor.png"];
                        break;
                    case TEAM_YELLOW:
                        gymImage = [UIImage imageNamed:@"Instinct.png"];
                        break;
                    default:
                        break;
                }

                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", annotationGym.guardPokemonID]]];
                imageView.frame = CGRectMake(0, 0, 50, 50);
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                view.leftCalloutAccessoryView = imageView;
                view.image = gymImage;
            }
        }
        else if ([annotation isKindOfClass:[PokestopAnnotation class]])
        {
            PokestopAnnotation *annotationPokestop = annotation;
            NSString *lureStr = [NSString stringWithFormat:@"%@", annotationPokestop.lure];
            
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:lureStr];
            
            if (!view) {
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:lureStr];
                view.canShowCallout = YES;
                
                UIImage *pokestopImage = [UIImage imageNamed:@"Pstop.png"];
                
                if(![lureStr isEqualToString:@"none"])
                    pokestopImage = [UIImage imageNamed:@"PstopLured.png"];
                
                view.image = pokestopImage;
            }
        }
        else if ([annotation isKindOfClass:[ScanAnnotation class]])
        {
            //ScanAnnotation *annotationScan = annotation;
            
            SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"scan"];
            
            if (!view) {
                
                pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"scan"];
                pulsingView.canShowCallout = YES;
                
                CGPoint point = view.center;
                point.x = (point.x + 20);
                point.y = (point.y + 20);
                
                pulsingView.annotationColor = [UIColor colorWithRed:0.10 green:0.74 blue:0.61 alpha:1.0];
            }
            
            return pulsingView;
        }
        
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!moved)
    {
        [self.mapview setCenterCoordinate:userLocation.location.coordinate animated:YES];
        moved = YES;
    }
}

-(void)hideAnnotations
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL pokemon    = YES;
    BOOL pokestop   = YES;
    BOOL gyms       = YES;
    
    if([prefs objectForKey:@"display_pokemons"] != nil)
        pokemon = [prefs boolForKey:@"display_pokemons"];
    
    if([prefs objectForKey:@"display_pokestops"] != nil)
        pokestop = [prefs boolForKey:@"display_pokestops"];
    
    if([prefs objectForKey:@"display_gyms"] != nil)
        gyms = [prefs boolForKey:@"display_gyms"];
    
    NSArray *annotations = [self.mapview annotations];
    
    for (int i = 0; i < [annotations count]; i++) {
        MKPointAnnotation *annotation = (MKPointAnnotation *)annotations[i];
        
        if([annotations[i] isKindOfClass:[PokemonAnnotation class]])
        {
            if(!pokemon)
                [self.mapview removeAnnotation:annotation];
        }
        
        if([annotations[i] isKindOfClass:[PokestopAnnotation class]])
        {
            if(!pokestop)
                [self.mapview removeAnnotation:annotation];
        }
        
        if([annotations[i] isKindOfClass:[GymAnnotation class]])
        {
            if(!gyms)
                [self.mapview removeAnnotation:annotation];
        }
    }
    
    self.requestStr = [self buildRequest];
    [self loadData];
}

-(void)refreshPokemons {
    NSArray *annotations = [self.mapview annotations];

    NSPredicate *filterPredicate = [NSComparisonPredicate
                                    predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject]
                                    rightExpression:[NSExpression expressionForConstantValue:[PokemonAnnotation class]]
                                    customSelector:@selector(isMemberOfClass:)];
    annotations = [annotations filteredArrayUsingPredicate:filterPredicate];
    [self.mapview removeAnnotations:annotations];
    [self.mapview addAnnotations:annotations];
}

-(void)mapCleaner
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            for (id <MKAnnotation> annotation in self.mapview.annotations)
            {
                if([annotation isKindOfClass:[PokemonAnnotation class]])
                {
                    PokemonAnnotation *annotationPoke = (PokemonAnnotation *)annotation;
                    
                    if([annotationPoke.expirationDate timeIntervalSinceNow] < 0.0)
                    {
                        NSLog(@"Pokemon removed %@", annotation.title);
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            [self.mapview removeAnnotation:annotation];
                        }];
                    }
                    else if((annotationPoke.hidePokemon == YES) && (isHideVeryCommonActivated == YES))
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                            [self.mapview removeAnnotation:annotation];
                        }];
                    }
                    
                }
            }
        });
}

-(void)locationAction:(id)sender
{
    region.center = self.mapview.userLocation.coordinate;
    region.span.latitudeDelta   = MAP_SCALE;
    region.span.longitudeDelta  = MAP_SCALE;
    [self.mapview setRegion:region animated:YES];
}

-(IBAction)radarAction:(id)sender
{
    if(radar.latitude != 0)
    {
        region.center = radar;
        region.span.latitudeDelta   = MAP_SCALE;
        region.span.longitudeDelta  = MAP_SCALE;
        [self.mapview setRegion:region animated:YES];
    }
}

- (UILabel*)timeLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    TimeLabel *timeLabel;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_timer"]) {
        timeLabel = [[TimerLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    } else {
        timeLabel = [[TimeLabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        
    }
    [timeLabel setDate:annotation.expirationDate];
    return timeLabel;
}

- (UILabel*)distanceLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    ;
    
    CLLocation *baseLocation = self.mapview.userLocation.location;
    
    if (!baseLocation) {
        baseLocation = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_lat"] longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_long"]];
    }

    CLLocationDistance distance = [pokemonLocation distanceFromLocation:baseLocation];
    
    DistanceLabel *distanceLabel = [[DistanceLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 20, frame.size.width, 20)];
    [distanceLabel setDistance:distance];
    return distanceLabel;
}

@end
