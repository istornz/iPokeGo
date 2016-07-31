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
    
    self.mapview.zoomEnabled        = true;
    moved                           = NO;
    firstConnection                 = YES;
    isNormalNotificationActivated   = YES;
    isFavNotificationActivated      = YES;
    isHideVeryCommonActivated       = NO;
    isVibrationActivated            = NO;
    isViewOnlyFav                   = NO;
    
    [self loadAnimatedImages];
    [self loadNavBar];
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
                                    alertControllerWithTitle:NSLocalizedString(@"Server not set", @"The title of an alert that tells the user, that no server was set.")
                                    message:NSLocalizedString(@"Please go in settings to enter server address", @"The message of an alert that tells the user, that no server was set.")
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"A common affirmative action title, like 'OK' in english.")
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

-(void)loadNavBar
{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIImage* image = [UIImage imageNamed:@"logo_app.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect frame = CGRectMake((self.view.center.x - 10), 0.0, 0, 20);
    imageView.frame = frame;
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    
    self.navigationItem.titleView = imageView;
}

-(void)loadAnimatedImages
{
    self.animatedPokestopLured = [NSArray arrayWithObjects:[UIImage imageNamed:@"Pokespot-Lured_0023_Frame-1.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0022_Frame-2.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0021_Frame-3.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0020_Frame-4.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0019_Frame-5.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0018_Frame-6.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0017_Frame-7.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0016_Frame-8.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0015_Frame-9.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0014_Frame-10.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0013_Frame-11.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0012_Frame-12.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0011_Frame-13.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0010_Frame-14.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0009_Frame-15.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0008_Frame-16.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0007_Frame-17.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0006_Frame-18.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0005_Frame-19.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0004_Frame-20.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0003_Frame-21.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0002_Frame-22.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0001_Frame-23.png"],
                                  [UIImage imageNamed:@"Pokespot-Lured_0000_Frame-24.png"], nil];
}

-(void)launchTimers
{

	UIApplication  *app = [UIApplication sharedApplication];
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideAnnotations)
                                                 name:@"HideRefresh"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedData)
                                                 name:@"LoadSaveData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(launchTimers)
                                                 name:@"LaunchTimers"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPokemons)
                                                 name:@"RefreshPokemons"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAnnotationLocalNotif:)
                                                 name:@"showAnnotationFromLocalNotif"
                                               object:nil];
    // Launch hack bacground mode
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appBackgrounding:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appForegrounding:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapview addGestureRecognizer:longPressGesture];
}

////// BEGIN MINE handleLongPressGesture
-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        if(radar.latitude == 0){
            CGPoint point = [sender locationInView:self.mapview];
            CLLocationCoordinate2D locCoord = [self.mapview convertPoint:point toCoordinateFromView:self.mapview];
            
            ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
            radar = locCoord;
            
            [prefs setObject:[NSNumber numberWithDouble:locCoord.latitude] forKey:@"radar_lat"];
            [prefs setObject:[NSNumber numberWithDouble:locCoord.longitude] forKey:@"radar_long"];
            
            [prefs synchronize];
            
            dropPin.coordinate = locCoord;
            dropPin.title = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
            
            for (int i = 0; i < [self.mapview.annotations count]; i++) {
                MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
                
                if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                    [self.mapview removeAnnotation:annotation];
            }
            
            [self sendNewLocationToServer:locCoord.latitude and:locCoord.longitude];
            [self.mapview addAnnotation:dropPin];
        }else{
            for (int i = 0; i < [self.mapview.annotations count]; i++) {
                MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
                
                if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                    [self.mapview removeAnnotation:annotation];
            }
            radar.latitude = 0;
            radar.longitude = 0;
            [prefs removeObjectForKey:@"radar_lat"];
            [prefs removeObjectForKey:@"radar_long"];
            [prefs synchronize];
            [self sendNewLocationToServer:self.mapview.userLocation.coordinate.latitude and:self.mapview.userLocation.coordinate.longitude];
        }
    }
}
////// END MINE handleLongPressGesture

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
	self.savedCommon                = [defaults objectForKey:@"pokemon_common"];
    self.mapLocation                = [defaults objectForKey:@"map_position"];
    
    if([defaults objectForKey:@"norm_notification"] != nil)
        isNormalNotificationActivated   = [defaults boolForKey:@"norm_notification"];
    
    if([defaults objectForKey:@"fav_notification"] != nil)
        isFavNotificationActivated      = [defaults boolForKey:@"fav_notification"];
    
    if([defaults objectForKey:@"vibration"] != nil)
        isVibrationActivated      = [defaults boolForKey:@"vibration"];
    
    if([defaults objectForKey:@"display_onlyfav"] != nil)
    {
        if(isViewOnlyFav != [defaults boolForKey:@"display_onlyfav"])
        {
            isViewOnlyFav       = [defaults boolForKey:@"display_onlyfav"];
            firstConnection     = YES;
        }
    }
    
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
        dropPin.title = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
        [self.mapview addAnnotation:dropPin];
    }
}

-(void)loadSoundFiles
{
    NSString *pathPokemonAppearSound    = [NSString stringWithFormat:@"%@/ding.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrlPokemonAppearSound   = [NSURL fileURLWithPath:pathPokemonAppearSound];
    
    NSString *pathPokemonFavAppearSound    = [NSString stringWithFormat:@"%@/favoritePokemon.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrlPokemonFavAppearSound   = [NSURL fileURLWithPath:pathPokemonFavAppearSound];
	
	AVAudioSession *audiosession = [AVAudioSession sharedInstance];
	[audiosession setCategory:AVAudioSessionCategoryAmbient error:nil];
	
    pokemonAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonAppearSound error:nil];
    pokemonFavAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonFavAppearSound error:nil];
}

-(void)loadLocalization {
    NSError *error;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"pokemon" withExtension:@"json"];
    
    self.localization = [[NSDictionary alloc] init];
    
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
                                      alertControllerWithTitle:NSLocalizedString(@"Location service denied", @"The title of an alert, that tells the user that he/she denied location access to the app.")
                                      message:NSLocalizedString(@"Location denied, please go in settings to allow this app to use your location", @"The message of an alert, that tells the user that he/she denied location access to the app.")
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"OK", @"A common affirmative action title, like 'OK' in english.")
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
    /*
    NSTimeInterval backgroundTimeRemaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    if (backgroundTimeRemaining != DBL_MAX)
        NSLog(@"Remaining time before background mode ending = %0.2f sec.", backgroundTimeRemaining);
    */
   
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
                                                       if ((myAnn.coordinate.latitude == [self.pokemons[i][@"latitude"] doubleValue]) && (myAnn.coordinate.longitude == [self.pokemons[i][@"longitude"] doubleValue]))
                                                       {
                                                           annFound = YES;
                                                           break;
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   PokemonAnnotation *point = [[PokemonAnnotation alloc] init];
                                                   CLLocationCoordinate2D pokemonLocation = CLLocationCoordinate2DMake([self.pokemons[i][@"latitude"] doubleValue], [self.pokemons[i][@"longitude"] doubleValue]);

                                                   NSString *disapearTime = [self.pokemons[i] valueForKey:@"disappear_time"];
                                                   double milliTime = disapearTime.doubleValue;
                                                   
                                                   NSDate *date = [NSDate dateWithTimeIntervalSince1970:(milliTime / 1000)];
                                                   
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
                                                           point.isFav          = [self isPokemonFavorite:key];
                                                           if((isViewOnlyFav == true) && (point.isFav == false))
                                                           {
                                                               // Nothing to do
                                                               // Option "view only fav" activated and the pokemon is not in fav list
                                                           }
                                                           else
                                                           {
                                                               point.hidePokemon    = isPokemonVeryCommonPokemon;
                                                               point.spawnpointID   = [self.pokemons[i] objectForKey:@"spawnpoint_id"];
                                                               point.expirationDate = date;
                                                               
                                                               point.coordinate     = pokemonLocation;
                                                               point.title          = [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]];
                                                               point.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."), [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]];
                                                               point.pokemonID      = [[self.pokemons[i] valueForKey:@"pokemon_id"] intValue];
                                                               
                                                               [self.mapview addAnnotation:point];
                                                               
                                                               if(!firstConnection)
                                                               {
                                                                   NSString *notificationMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] was added to the map!", @"The hint that a certain Pokémon appeared on the map.") , point.title];
                                                                   
                                                                   if(point.isFav)
                                                                   {
                                                                       NSLog(@"FAV Pokemon added on map !!");
                                                                       
                                                                       notificationMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] your favorite pokemon was added to the map!", @"The hint that a favorite Pokémon appeared on the map.") , point.title];
                                                                       
                                                                       if(isFavNotificationActivated)
                                                                       {
                                                                           self.notification = [CWStatusBarNotification new];
                                                                           self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];;
                                                                           self.notification.notificationLabelTextColor = [UIColor whiteColor];
                                                                           
                                                                           [pokemonFavAppearSound play];
                                                                           if(isVibrationActivated)
                                                                           {
                                                                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                                                                           }
                                                                           
                                                                           [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                           
                                                                           [self launchNotification:point.title isFav:point.isFav lat:[self.pokemons[i][@"latitude"] doubleValue] lng:[self.pokemons[i][@"longitude"] doubleValue]];
                                                                           
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
                                                                           self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0];;
                                                                           self.notification.notificationLabelTextColor = [UIColor whiteColor];

                                                                           [pokemonAppearSound play];
                                                                           if(isVibrationActivated)
                                                                           {
                                                                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                                                                           }
                                                                           
                                                                           [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                           
                                                                           [self launchNotification:point.title isFav:point.isFav lat:[self.pokemons[i][@"latitude"] doubleValue] lng:[self.pokemons[i][@"longitude"] doubleValue]];
                                                                           
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
                                       
                                       ////// BEGIN MINE POKEMON LURED
                                       self.pokestops = jsonData[@"pokestops"];
                                       
                                       if([self.pokestops count] > 0)
                                       {
                                           for (int i = 0; i < [self.pokestops count]; i++) {
                                               if(![[self.pokestops[i] valueForKey:@"active_pokemon_id"] isKindOfClass:[NSNull class]])
                                               {
                                                   for (id<MKAnnotation> ann in self.mapview.annotations)
                                                   {
                                                       annFound = NO;
                                                       if ([ann isKindOfClass:[PokemonAnnotation class]])
                                                       {
                                                           PokemonAnnotation *myAnn = (PokemonAnnotation *)ann;
                                                           if ((myAnn.coordinate.latitude == [self.pokestops[i][@"latitude"] doubleValue] + 0.0002) && (myAnn.coordinate.longitude == [self.pokestops[i][@"longitude"] doubleValue] + 0.0002))
                                                           {
                                                               annFound = YES;
                                                               break;
                                                           }
                                                       }
                                                   }
                                               } else {
                                                   annFound = YES;
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   PokemonAnnotation *point = [[PokemonAnnotation alloc] init];
                                                   CLLocationCoordinate2D pokemonLocation = CLLocationCoordinate2DMake([self.pokestops[i][@"latitude"] doubleValue] + 0.0002, [self.pokestops[i][@"longitude"] doubleValue] + 0.0002);
                                                   
                                                   NSString *disapearTime = [self.pokestops[i] valueForKey:@"lure_expiration"];
                                                   double milliTime = disapearTime.doubleValue;
                                                   
                                                   NSDate *date = [NSDate dateWithTimeIntervalSince1970:(milliTime / 1000)];
                                                   
                                                   NSString *key    = [self.pokestops[i] objectForKey:@"active_pokemon_id"];
                                                   
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
                                                           point.isFav          = [self isPokemonFavorite:key];
                                                           if((isViewOnlyFav == true) && (point.isFav == false))
                                                           {
                                                               // Nothing to do
                                                               // Option "view only fav" activated and the pokemon is not in fav list
                                                           }
                                                           else
                                                           {
                                                               point.hidePokemon    = isPokemonVeryCommonPokemon;
                                                               point.spawnpointID   = [self.pokestops[i] objectForKey:@"pokestop_id"];
                                                               point.expirationDate = date;
                                                               
                                                               point.coordinate     = pokemonLocation;
                                                               point.title       = [NSString localizedStringWithFormat:NSLocalizedString(@"%@ (Pokestop)", @"The title of a annotation callout for a Pokémon lured."), [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]]];
                                                               point.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."), [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]];
                                                               point.pokemonID      = [[self.pokestops[i] valueForKey:@"active_pokemon_id"] intValue];
                                                               
                                                               [self.mapview addAnnotation:point];
                                                               
                                                               if(!firstConnection)
                                                               {
                                                                   NSString *notificationMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] was added to the map!", @"The hint that a certain Pokémon appeared on the map.") , [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]]];
                                                                   
                                                                   if(point.isFav)
                                                                   {
                                                                       NSLog(@"FAV Pokemon added on map !!");
                                                                       
                                                                       notificationMessage = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] your favorite pokemon was added to the map!", @"The hint that a favorite Pokémon appeared on the map.") , [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]]];
                                                                       
                                                                       if(isFavNotificationActivated)
                                                                       {
                                                                           self.notification = [CWStatusBarNotification new];
                                                                           self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];;
                                                                           self.notification.notificationLabelTextColor = [UIColor whiteColor];
                                                                           
                                                                           [pokemonFavAppearSound play];
                                                                           if(isVibrationActivated)
                                                                           {
                                                                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                                                                           }
                                                                           
                                                                           [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                           
                                                                           [self launchNotification:[self.localization objectForKey:[NSString stringWithFormat:@"%@", key]] isFav:point.isFav lat:[self.pokestops[i][@"latitude"] doubleValue] + 0.0002 lng:[self.pokestops[i][@"longitude"] doubleValue] + 0.0002];
                                                                           
                                                                           __weak typeof(self) weakSelf = self;
                                                                           self.notification.notificationTappedBlock = ^(void) {
                                                                               [weakSelf.mapview showAnnotations:@[point] animated:YES];
                                                                           };
                                                                       }
                                                                   }
                                                                   else
                                                                   {
                                                                       NSLog(@"Pokemon added on map %@", [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]]);
                                                                       if(isNormalNotificationActivated)
                                                                       {
                                                                           self.notification = [CWStatusBarNotification new];
                                                                           self.notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.15 green:0.20 blue:0.23 alpha:1.0];;
                                                                           self.notification.notificationLabelTextColor = [UIColor whiteColor];
                                                                           [pokemonAppearSound play];
                                                                           if(isVibrationActivated)
                                                                           {
                                                                               AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
                                                                           }
                                                                           
                                                                           [self.notification displayNotificationWithMessage:notificationMessage forDuration:4.5f];
                                                                           
                                                                           [self launchNotification:[self.localization objectForKey:[NSString stringWithFormat:@"%@", key]] isFav:point.isFav lat:[self.pokestops[i][@"latitude"] doubleValue] + 0.0002 lng:[self.pokestops[i][@"longitude"] doubleValue] + 0.0002];

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
                                       ////// END MINE POKEMON LURED
                                    
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
                                                   ////// BEGIN MINE
                                                   annFound = NO;
                                                   ////// END MINE
                                                   if ([ann isKindOfClass:[PokestopAnnotation class]])
                                                   {
                                                       PokestopAnnotation *myAnn = (PokestopAnnotation *)ann;
                                                       if ((myAnn.coordinate.latitude == [self.pokestops[i][@"latitude"] doubleValue]) && (myAnn.coordinate.longitude == [self.pokestops[i][@"longitude"] doubleValue]))
                                                       {
                                                           ////// BEGIN MINE TEST MAJ POKESTOP
                                                           NSString *lureStr = [NSString stringWithFormat:@"%@", myAnn.lure];
                                                           if( (([[self.pokestops[i] valueForKey:@"lure_expiration"] isKindOfClass:[NSNull class]]) && (![lureStr isEqualToString:@"none"])) || ((![[self.pokestops[i] valueForKey:@"lure_expiration"] isKindOfClass:[NSNull class]]) && ([lureStr isEqualToString:@"none"])) )
                                                           {
                                                               [self.mapview removeAnnotation:myAnn];
                                                               NSLog(@"Pokestop changed");
                                                               break;
                                                           }
                                                           else
                                                           {
                                                               annFound = YES;
                                                               break;
                                                           }
                                                           ////// END MINE TEST MAJ POKESTOP
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   PokestopAnnotation *point = [[PokestopAnnotation alloc] init];
                                                   CLLocationCoordinate2D pokestopLocation = CLLocationCoordinate2DMake([self.pokestops[i][@"latitude"] doubleValue], [self.pokestops[i][@"longitude"] doubleValue]);
                                                   
                                                   point.coordinate = pokestopLocation;
                                                   ////// BEGIN MINE CHANGE
                                                   point.last_modified = [self.pokestops[i] valueForKey:@"last_modified"];
                                                   point.pokestopID = [[self.pokestops[i] valueForKey:@"pokestop_id"] intValue];
                                                   point.title      = NSLocalizedString(@"Pokestop", @"The title of a Pokéstop annotation on the map.");
                                                   if([[self.pokestops[i] valueForKey:@"lure_expiration"] isKindOfClass:[NSNull class]]){
                                                       point.lure       = @"none";
                                                       point.subtitle = NSLocalizedString(@"Not lured", @"The description of a Pokéstop not lured annotation on the map.");
                                                   }
                                                   else
                                                   {
                                                       point.lure = [self.pokestops[i] valueForKey:@"lure_expiration"];
                                                       NSString *last_modified = [self.pokestops[i] valueForKey:@"last_modified"];
                                                       double milliTime = last_modified.doubleValue;
                                                       milliTime = (milliTime / 1000) + 1800;
                                                       NSDate *date = [NSDate dateWithTimeIntervalSince1970:milliTime];
                                                       point.subtitle = [NSString localizedStringWithFormat:NSLocalizedString(@"Lured until", @"The hint in a annotation callout that indicates when a Pokéstop become not lured."), [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle]];
                                                   }
                                                   ////// END MINE CHANGE
                                                   point.title      = NSLocalizedString(@"Pokestop", @"The title of a Pokéstop annotation on the map.");
                                                   
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
                                                   ////// BEGIN MINE
                                                   annFound = NO;
                                                   ////// END MINE
                                                   if ([ann isKindOfClass:[GymAnnotation class]])
                                                   {
                                                       GymAnnotation *myAnn = (GymAnnotation *)ann;
                                                       if ((myAnn.coordinate.latitude == [self.gyms[i][@"latitude"] doubleValue]) && (myAnn.coordinate.longitude == [self.gyms[i][@"longitude"] doubleValue]))
                                                       {
                                                           ////// BEGIN MINE TEST MAJ GYM
                                                           if( (myAnn.gymsID != [[self.gyms[i] valueForKey:@"team_id"] intValue]) || (myAnn.guardPokemonID != [[self.gyms[i] valueForKey:@"guard_pokemon_id"] intValue]) || (myAnn.gym_points != [[self.gyms[i] valueForKey:@"gym_points"] intValue])  )
                                                           {
                                                               [self.mapview removeAnnotation:myAnn];
                                                               NSLog(@"Gym changed");
                                                               break;
                                                           }
                                                           else
                                                           {
                                                               annFound = YES;
                                                               break;
                                                           }
                                                           ////// END MINE TEST MAJ GYM
                                                       }
                                                   }
                                               }
                                               
                                               if (!annFound)
                                               {
                                                   GymAnnotation *point = [[GymAnnotation alloc] init];
                                                   CLLocationCoordinate2D gymLocation = CLLocationCoordinate2DMake([self.gyms[i][@"latitude"] doubleValue], [self.gyms[i][@"longitude"] doubleValue]);
                                                   
                                                   point.coordinate     = gymLocation;
                                                   ////// BEGIN MINE TITLE GYM
                                                   point.gymsID         = [[self.gyms[i] valueForKey:@"team_id"] intValue];
                                                   switch (point.gymsID) {
                                                       case TEAM_BLUE:
                                                           point.title = NSLocalizedString(@"Blue Gym", @"The title of a blue gym annotation on the map.");
                                                           break;
                                                       case TEAM_RED:
                                                           point.title = NSLocalizedString(@"Red Gym", @"The title of a red gym annotation on the map.");
                                                           break;
                                                       case TEAM_YELLOW:
                                                           point.title = NSLocalizedString(@"Yellow Gym", @"The title of a yellow gym annotation on the map.");
                                                           break;
                                                       default:
                                                           point.title = NSLocalizedString(@"Uncontested Gym", @"The title of an uncontested gym annotation on the map.");
                                                           break;
                                                   }
                                                   ////// END MINE TITLE GYM
                                                   point.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Gym points: %d", @"The description of a gym annotation on the map with points."), [self.gyms[i][@"gym_points"] intValue]];
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

-(BOOL)isPokemonFavorite:(NSString *)pokemonIDArg
{
    BOOL state = NO;
    if([self.savedFavorite count] > 0)
    {
        for (NSString *pokemonID in self.savedFavorite) {
            if ([pokemonID intValue] == [pokemonIDArg intValue]) {
                state = YES;
                break;
            }
        }
    }
    
    return state;
}

-(BOOL)isPokemonVeryCommon:(NSString *)idPokeToTest
{
    BOOL returnState = NO;

    for (int i = 0; i < [self.savedCommon count]; i++) {
        NSString *idTab = [self.savedCommon objectAtIndex:i];
        
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
            ////// BEGIN MINE GYM IDENTIFIER
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%d+%d",annotationGym.gymsID,annotationGym.guardPokemonID]];
            ////// END MINE GYM IDENTIFIER
            if (!view) {
                
                ////// BEGIN MINE DRIVE BUTTON
                UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *btnImage   = [UIImage imageNamed:@"drive"];
                button.frame = CGRectMake(0, 0, 30, 30);
                [button setImage:btnImage forState:UIControlStateNormal];
                ////// END MINE DRIVE BUTTON
                
                ////// BEGIN MINE GYM IDENTIFIER
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%d+%d",annotationGym.gymsID,annotationGym.guardPokemonID]];
                ////// END MINE GYM IDENTIFIER
                view.canShowCallout = YES;
                
                ////// BEGIN MINE DRIVE BUTTON
                view.rightCalloutAccessoryView = button;
                ////// END MINE DRIVE BUTTON
                
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
                ////// BEGIN MINE VIEW GUARDPOKEMON
                if(annotationGym.gymsID != 0){
                    UIImage *largeImage = [UIImage imageNamed : @"icons-hd.png"];
                    int x = (annotationGym.guardPokemonID - 1)%SPRITESHEET_COLS*SPRITE_SIZE;
                    int y = annotationGym.guardPokemonID;
                    while(y%SPRITESHEET_COLS != 0) y++;
                    y = (y/SPRITESHEET_COLS - 1) * SPRITE_SIZE;
                    CGRect cropRect = CGRectMake(x, y, SPRITE_SIZE, SPRITE_SIZE);
                    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                    imageView.image = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    view.leftCalloutAccessoryView = imageView;
                }
                ////// END MINE VIEW GUARDPOKEMON
                view.image = gymImage;
            }
        }
        else if ([annotation isKindOfClass:[PokestopAnnotation class]])
        {
            PokestopAnnotation *annotationPokestop = annotation;
            NSString *lureStr = [NSString stringWithFormat:@"%@", annotationPokestop.lure];
            
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:lureStr];
            
            if (!view) {

                ////// BEGIN MINE DRIVE BUTTON
                UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *btnImage   = [UIImage imageNamed:@"drive"];
                button.frame = CGRectMake(0, 0, 30, 30);
                [button setImage:btnImage forState:UIControlStateNormal];
                ////// END MINE DRIVE BUTTON
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:lureStr];
                view.canShowCallout = YES;

                ////// BEGIN MINE DRIVE BUTTON
                view.rightCalloutAccessoryView = button;
                ////// END MINE DRIVE BUTTON
                
                UIImage *pokestopImage = [UIImage imageNamed:@"Pstop.png"];
                
                if(![lureStr isEqualToString:@"none"])
                {
                    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
                    animatedImageView.animationImages = self.animatedPokestopLured;
                    animatedImageView.animationDuration = 1.0f;
                    [animatedImageView setFrame:CGRectMake(0, 0, 30, 30)];
                    [animatedImageView startAnimating];
                    [view addSubview: animatedImageView];
                }
                
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
	
	for (id <MKAnnotation> annotation in annotations)
	{
		PokemonAnnotation *annotationPoke = (PokemonAnnotation *)annotation;
		
		annotationPoke.hidePokemon = [self isPokemonVeryCommon:[[NSNumber numberWithInt:annotationPoke.pokemonID] stringValue]];
        annotationPoke.isFav       = [self isPokemonFavorite:[[NSNumber numberWithInt:annotationPoke.pokemonID] stringValue]];
	}
	
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
                    else if((annotationPoke.isFav == NO) && (isViewOnlyFav == YES))
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
        ////// BEGIN MINE
        timeLabel = [[TimerLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 5, frame.size.width, 20)];
        ////// END MINE
    } else {
        ////// BEGIN MINE
        timeLabel = [[TimeLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 5, frame.size.width, 20)];
        ////// END MINE
        
    }
    [timeLabel setDate:annotation.expirationDate];
    return timeLabel;
}

- (UILabel*)distanceLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    
    CLLocation *baseLocation = self.mapview.userLocation.location;
    
    if (!baseLocation) {
        baseLocation = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_lat"] longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_long"]];
    }

    CLLocationDistance distance = [pokemonLocation distanceFromLocation:baseLocation];
    ////// BEGIN MINE
    DistanceLabel *distanceLabel = [[DistanceLabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 60, frame.size.width, 20)];
    [distanceLabel setDistance:distance];
    ////// END MINE
    return distanceLabel;
}

-(void)launchNotification:(NSString *)pokemonTitle isFav:(BOOL)fav lat:(double)lat lng:(double)lng
{
    NSString *message   = nil;
    NSString *soundName = nil;
    
    if(fav)
    {
        message     = [NSString stringWithFormat:NSLocalizedString(@"[Pokemon] your favorite pokemon was added to the map!", @"The hint that a favorite Pokémon appeared on the map.") , pokemonTitle];
        soundName   = @"favoritePokemon.mp3";
    }
    else
    {
        message = [NSString stringWithFormat:NSLocalizedString(@"[Pokemon] was added to the map!", @"The hint that a certain Pokémon appeared on the map.") , pokemonTitle];
        soundName   = @"ding.mp3";
    }
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithDouble:lat], [NSNumber numberWithDouble:lng]] forKeys:@[@"latitude", @"longitude"]];
    
    UILocalNotification *localN         = [[UILocalNotification alloc] init];
    localN.fireDate                     = [NSDate date];
    localN.alertBody                    = message;
    localN.timeZone                     = [NSTimeZone defaultTimeZone];
    localN.soundName                    = soundName;
    localN.userInfo                     = infoDict;
    localN.applicationIconBadgeNumber   = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localN];
}

#pragma mark - Receive local notification

-(void)showAnnotationLocalNotif:(NSNotification *)notification
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude     = [[notification.userInfo objectForKey:@"latitude"] doubleValue];
    coordinate.longitude    = [[notification.userInfo objectForKey:@"longitude"] doubleValue];
    
    region.center = coordinate;
    region.span.latitudeDelta   = MAP_SCALE_ANNOT;
    region.span.longitudeDelta  = MAP_SCALE_ANNOT;
    
    [self.mapview setRegion:region animated:YES];
}

#pragma mark - Hack background mode

//TODO: Find a legal way to make the background task infinite or more longer than 3min
- (void)appBackgrounding:(NSNotification *)notification {
    // This is an hack to run the app indefinitely in background mode
    [self keepAlive];
}

- (void)keepAlive {
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
        [self keepAlive];
    }];
}

- (void)appForegrounding: (NSNotification *)notification {
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

@end
