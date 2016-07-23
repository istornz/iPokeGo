//
//  ViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "MapViewController.h"

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
    moved           = NO;
    firstConnection = YES;
    
    [[NSNotificationCenter defaultCenter]
                                        addObserver:self
                                        selector:@selector(hideAnnotations)
                                        name:@"HideRefresh"
                                        object:nil];
    
    [self loadLocalization];
    [self checkGPS];
    [self loadSoundFiles];
    self.requestStr = [self buildRequest];
    
    if(self.requestStr != nil)
    {
        self.timerData = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(loadData)
                                                        userInfo:nil
                                                         repeats:YES];
        
        self.timerDataCleaner = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(mapCleaner)
                                                               userInfo:nil
                                                                repeats:YES];
        
    }
    else
    {
        //ALERTE
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadSoundFiles
{
    NSString *pathPokemonAppearSound    = [NSString stringWithFormat:@"%@/ding.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrlPokemonAppearSound   = [NSURL fileURLWithPath:pathPokemonAppearSound];
    
    pokemonAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonAppearSound error:nil];
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
    PokemonAnnotation *annotation = nil;
    for (int i=0; i<[annotations count]; i++)
    {
        annotation = (PokemonAnnotation *)[annotations objectAtIndex:i];
        if (self.mapview.region.span.latitudeDelta > .15)
        {
            [[self.mapview viewForAnnotation:annotation] setHidden:YES];
        }
        else {
            [[self.mapview viewForAnnotation:annotation] setHidden:NO];
        }
    }
    
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
    
    [self performSelector:@selector(locationAction:) withObject:nil afterDelay:0];
}

-(void)loadData
{
    //Loading in background
    
    /*************************************/
    //           Requête POST            //
    /*************************************/
#pragma mark Requête POST
    
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
                                                   
                                                   if(![self isPokemonVeryCommon:[NSString stringWithFormat:@"%@", key]])
                                                   {
                                                       point.spawnpointID   = [self.pokemons[i] objectForKey:@"spawnpoint_id"];
                                                       point.expirationDate = date;
                                                       point.coordinate     = pokemonLocation;
                                                       point.title          = [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]];
                                                       point.subtitle       = [NSString stringWithFormat:@"Disappears at %02d:%02d:%02d", (int)hour, (int)minute, (int)second];
                                                       point.pokemonID      = [[self.pokemons[i] valueForKey:@"pokemon_id"] intValue];
                                                       
                                                       NSLog(@"Pokemon added on map");
                                                       
                                                       [self.mapview addAnnotation:point];
                                                       
                                                       if(!firstConnection)
                                                       {
                                                           [pokemonAppearSound play];
                                                           
                                                           self.notification = [CWStatusBarNotification new];
                                                           [self.notification displayNotificationWithMessage:[NSString stringWithFormat:@"%@ was added on the map !", point.title]forDuration:4.0f];
                                                           
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
                                                   point.title      = @"Pokéstop";
                                                   point.subtitle   = @"";
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
                                                   point.subtitle       = @"";
                                                   point.gymsID         = [[self.gyms[i] valueForKey:@"team_id"] intValue];
                                                   point.guardPokemonID = [[self.gyms[i] valueForKey:@"guard_pokemon_id"] intValue];
                                                   point.gym_points     = [[self.gyms[i] valueForKey:@"gym_points"] intValue];
                                                   
                                                   [self.mapview addAnnotation:point];
                                               }
                                           }
                                       }
                                 
                                    firstConnection = NO;
                               }
                               else
                               {
                                   NSLog(@"%@", error);
                               }
                                   
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
    
    NSString *request = SERVER_API;
    self.display_pokemons_str  = @"true";
    self.display_pokestops_str = @"true";
    self.display_gyms_str      = @"true";
    
    if([server_addr length] > 0)
    {
        if([defaults objectForKey:@"display_pokemons"] != nil)
        {
            if(!display_pokemons)
                self.display_pokemons_str = @"false";
        }
        
        if([defaults objectForKey:@"display_pokestops"] != nil)
        {
            if(!display_pokestops)
                self.display_pokestops_str = @"false";
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
    }
    else
    {
        request = nil;
    }
    
    return request;
}
                                                  
-(BOOL)isPokemonVeryCommon:(NSString *)idPokeToTest
{
    for (int i = 0; i < [self.verycommon count]; i++) {
        NSString *idTab = [self.verycommon objectAtIndex:i];
        
        if ([idPokeToTest isEqualToString:idTab])
            return YES;
    }
    
    return NO;
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView *view = nil;
    
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
                view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", annotationPokemon.pokemonID]];
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
                
                view.image = gymImage;
            }
        }
        else if ([annotation isKindOfClass:[PokestopAnnotation class]])
        {
            PokestopAnnotation *annotationPokestop = annotation;
            NSString *lureStr = [NSString stringWithFormat:@"%@", annotationPokestop.lure];
            view.canShowCallout = YES;
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:lureStr];
            if (!view) {
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:lureStr];
                
                UIImage *pokestopImage = [UIImage imageNamed:@"Pstop.png"];
                
                if(![lureStr isEqualToString:@"none"])
                    pokestopImage = [UIImage imageNamed:@"PstopLured.png"];
                
                view.image = pokestopImage;
            }
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
                        NSLog(@"Pokemon removed");
                        
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

@end
