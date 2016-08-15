//
//  ViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "MapViewController.h"
#import "CoreDataPersistance.h"
#import "CoreDataEntities.h"
#import "SettingsTableViewController.h"
#import "iPokeServerSync.h"
#import "GymAnnotationView.h"
#import "PokeStopAnnotationView.h"
#import "PokemonAnnotationView.h"
#import <AudioToolbox/AudioServices.h>
#import "CWStatusBarNotification.h"
#import "FollowLocationHelper.h"
@import CoreData;

@interface MapViewController() <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate>

@property NSFetchedResultsController *gymFetchResultController;
@property NSFetchedResultsController *pokemonFetchResultController;
@property NSFetchedResultsController *pokestopFetchResultController;

@property NSMutableArray *annotationsToAdd;
@property NSMutableArray *annotationsPokemonToDelete;
@property NSMutableArray *annotationsGymsToDelete;
@property NSMutableArray *annotationsPokeStopsToDelete;

@property CLLocationManager *locationManager;
@property NSDictionary *localization;
@property CLLocationDegrees oldLatitudeDelta;

@property FollowLocationHelper *followLocationHelper;

@end

@implementation MapViewController

static CLLocationDegrees DeltaHideAllIcons = 0.2;
static CLLocationDegrees DeltaHideText = 0.1;
BOOL regionChangeRequested      = YES;
BOOL followLocationEnabled      = NO;
BOOL flagIsPanning              = NO;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self loadLocalization];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appSwitchedToActiveState) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appSwitchedToBackgroundState) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.oldLatitudeDelta = self.mapview.region.span.latitudeDelta;
    self.followLocationHelper = [[FollowLocationHelper alloc] init];
    
    [self loadNavBar];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapview addGestureRecognizer:longPressGesture];
    
    UILongPressGestureRecognizer *longPressGPSButtonGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGPSButtonGesture:)];
    [self.locationButton addGestureRecognizer:longPressGPSButtonGesture];
    
    [self enableFollowLocation:NO];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGesture setDelegate:self];
    [self.mapview addGestureRecognizer:panGesture];
    
    
    //default to the last known position
    NSDictionary *mapLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"map_position"];
    if([mapLocation count] > 0) {
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([[mapLocation objectForKey:@"latitude"] doubleValue],
                                                                                      [[mapLocation objectForKey:@"longitude"] doubleValue]),
                                                           MKCoordinateSpanMake([[mapLocation objectForKey:@"latitudeDelta"] doubleValue],
                                                                                [[mapLocation objectForKey:@"longitudeDelta"] doubleValue]));
        
        [self.mapview setRegion:region animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadMap];
    [self checkGPS];
    [self loadMapPreferences];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"server_addr"] length] == 0) {
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self disconnectUpdates];
}

- (void)appSwitchedToActiveState
{
    [self reloadMap];
    [self checkGPS];
}

- (void)appSwitchedToBackgroundState
{
    [self disconnectUpdates];
}

-(void)checkGPS
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            //lets only show this once per app run so users can't get spammed
            //Location Services is off from settings
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"Location service denied", @"The title of an alert, that tells the user that he/she denied location access to the app.")
                                        message:NSLocalizedString(@"Location denied, please go in settings to allow this app to use your location", @"The message of an alert, that tells the user that he/she denied location access to the app.")
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", @"A common affirmative action title, like 'OK' in english.")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                 }];
            
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)loadMapPreferences
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"map_type_standard"])
        [self.mapview setMapType:MKMapTypeStandard];
    else
        [self.mapview setMapType:MKMapTypeHybridFlyover];
}

- (void)updateLocationInServer:(CLLocation *)location
{
    NSLog(@"Set new location in server");
    [self.followLocationHelper updateLocation:location];
    iPokeServerSync *server = [[iPokeServerSync alloc] init];
    [server setLocation:location.coordinate];
}

- (void)enableFollowLocation:(BOOL)enable
{
    if(followLocationEnabled != enable) {
        NSLog(@"Enable follow location %s", enable ? "YES" : "NO");
        followLocationEnabled = enable;
        self.mapview.tintAdjustmentMode = enable ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
        
        CWStatusBarNotification *notification = [CWStatusBarNotification new];
        NSString *notifMsg = nil;
        if(followLocationEnabled) {
            notifMsg = @"Follow location enabled";
            notification.notificationLabelBackgroundColor = NOTIF_FOLLOW_GREEN_COLOR;
            
        } else {
            notifMsg = @"Follow location disabled";
            notification.notificationLabelBackgroundColor = NOTIF_FOLLOW_RED_COLOR;
        }
        
        [notification displayNotificationWithMessage:notifMsg
                                         forDuration:1.0f];
    }
}

#pragma mark - Gesture recognizers

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self enableFollowLocation:NO];
        
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        CGPoint point = [sender locationInView:self.mapview];
        CLLocationCoordinate2D coordinate = [self.mapview convertPoint:point toCoordinateFromView:self.mapview];
        
        ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
        dropPin.coordinate = coordinate;
        dropPin.title = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
        
        [self.radarButton setHidden:NO];
        
        for (int i = 0; i < [self.mapview.annotations count]; i++) {
            MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
            if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                [self.mapview removeAnnotation:annotation];
        }
        [self.mapview addAnnotation:dropPin];
        
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
        [self updateLocationInServer:location];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"radar_lat"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"radar_long"];
    }
}

-(void)handleLongPressGPSButtonGesture:(UIGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        [self enableFollowLocation:YES];
        
        // remove scan annotation from map
        for (id <MKAnnotation> annotation in self.mapview.annotations)
        {
            if ([annotation isKindOfClass:[ScanAnnotation class]])
            {
                [self.mapview removeAnnotation:annotation];
            }
            
        }
        // remove scan location coordinates from user defaults
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"radar_lat"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"radar_long"];
        
        [self checkGPS];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handlePanGesture:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        flagIsPanning = YES;
        if (gestureRecognizer.numberOfTouches == 1){
            [self enableFollowLocation:NO];
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        flagIsPanning = NO;
    }
}


#pragma mark - Mapview delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if ((self.mapview.region.span.latitudeDelta < DeltaHideText && self.oldLatitudeDelta > DeltaHideText) || (self.mapview.region.span.latitudeDelta > DeltaHideText && self.oldLatitudeDelta < DeltaHideText) ||
        (self.mapview.region.span.latitudeDelta < DeltaHideAllIcons && self.oldLatitudeDelta > DeltaHideAllIcons) || (self.mapview.region.span.latitudeDelta > DeltaHideAllIcons && self.oldLatitudeDelta < DeltaHideAllIcons)) {
        NSArray *annotations = self.mapview.annotations;
        [self.mapview removeAnnotations:annotations];
        [self.mapview addAnnotations:annotations];
    }
    self.oldLatitudeDelta = self.mapview.region.span.latitudeDelta;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *mapRegion = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithDouble:self.mapview.region.center.latitude], [NSNumber numberWithDouble:self.mapview.region.center.longitude], [NSNumber numberWithDouble:self.mapview.region.span.latitudeDelta], [NSNumber numberWithDouble:self.mapview.region.span.longitudeDelta]] forKeys:@[@"latitude", @"longitude", @"latitudeDelta", @"longitudeDelta"]];
    
    [prefs setObject:mapRegion forKey:@"map_position"];
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = nil;
    if ((id<MKAnnotation>)annotation != mapView.userLocation) {
        if([annotation isKindOfClass:[PokemonAnnotation class]])
        {
            PokemonAnnotation *annotationPokemon = annotation;
            NSString *reuse = [NSString stringWithFormat:@"pokemon_%@", @(annotationPokemon.pokemonID)];
            view = (PokemonAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
                        
            if (!view) {
                view = [[PokemonAnnotationView alloc] initWithAnnotation:annotationPokemon currentLocation:[self currentLocation] reuseIdentifier:reuse];
            } else {
                [((PokemonAnnotationView *)view) setAnnotation:annotation withLocation:[self currentLocation]];
            }
            view.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideAllIcons;
            ((PokemonAnnotationView *)view).timeLabel.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideText;
            ((PokemonAnnotationView *)view).timerLabel.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideText;
            ((PokemonAnnotationView *)view).distanceLabel.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideText;
        }
        else if ([annotation isKindOfClass:[GymAnnotation class]])
        {
            GymAnnotation *annotationGym = annotation;
            NSString *reuse = [NSString stringWithFormat:@"gym_%@", @(annotationGym.teamID)];
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
            if (!view) {
                view = [[GymAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
            } else {
                view.annotation = annotationGym;
            }
            
            view.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideAllIcons;
        }
        else if ([annotation isKindOfClass:[PokestopAnnotation class]])
        {
            PokestopAnnotation *annotationPokestop = annotation;
            NSString *reuse = annotationPokestop.hasLure ? @"pokestop" : @"pokestop_lured";
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
            
            if (!view) {
                view = [[PokeStopAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
            } else {
                view.annotation = annotation;
            }
            
            view.hidden = self.mapview.region.span.latitudeDelta >= DeltaHideAllIcons;
        }
        else if ([annotation isKindOfClass:[ScanAnnotation class]])
        {
            SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"scan"];
            if (!view) {
                pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"scan"];
                pulsingView.canShowCallout = YES;
                pulsingView.annotationColor = [UIColor colorWithRed:0.10 green:0.74 blue:0.61 alpha:1.0];
            }
            
            view = pulsingView;
        }
        
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D endingCoord = CLLocationCoordinate2DMake(view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
    NSString *drivingMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"driving_mode"];
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:drivingMode forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    for (CLLocation *location in locations) {
        //make sure it is reasonably fresh, say the last 30 seconds
        if ([location.timestamp timeIntervalSinceNow] > -30) {
            if (followLocationEnabled){
                if ([self.followLocationHelper mustUpdateLocation:location]){
                    [self updateLocationInServer:location];
                }
                if (!flagIsPanning){
                    [self.mapview setCenterCoordinate:location.coordinate animated:YES];
                }
            }else{
                if(regionChangeRequested) {
                    regionChangeRequested = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(MAP_SCALE, MAP_SCALE));
                        [self.mapview setRegion:region animated:YES];
                    });
                }
                [self.locationManager stopUpdatingLocation];
                break;
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - FRC Delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
        {
            if ([anObject isKindOfClass:[Pokemon class]]) {
                Pokemon *pokemon = (Pokemon *)anObject;
                [self.annotationsPokemonToDelete addObject:pokemon.spawnpoint];
            } else if ([anObject isKindOfClass:[Gym class]]) {
                Gym *gym = (Gym *)anObject;
                [self.annotationsGymsToDelete addObject:gym.identifier];
            } else if ([anObject isKindOfClass:[PokeStop class]]) {
                PokeStop *pokeStop = (PokeStop *)anObject;
                [self.annotationsPokeStopsToDelete addObject:pokeStop.identifier];
            }
            break;
        }
        case NSFetchedResultsChangeInsert:
        {
            if ([anObject isKindOfClass:[Pokemon class]]) {
                Pokemon *pokemon = (Pokemon *)anObject;
                PokemonAnnotation *point = [[PokemonAnnotation alloc] initWithPokemon:pokemon andLocalization:self.localization];
                [self.annotationsToAdd addObject:point];
                
            } else if ([anObject isKindOfClass:[Gym class]]) {
                Gym *gym = (Gym *)anObject;
                GymAnnotation *point = [[GymAnnotation alloc] initWithGym:gym];
                [self.annotationsToAdd addObject:point];
                
            } else if ([anObject isKindOfClass:[PokeStop class]]) {
                PokeStop *pokeStop = (PokeStop *)anObject;
                PokestopAnnotation *point = [[PokestopAnnotation alloc] initWithPokestop:pokeStop];
                [self.annotationsToAdd addObject:point];
            }
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            if ([anObject isKindOfClass:[Pokemon class]]) {
                Pokemon *pokemon = (Pokemon *)anObject;
                [self.annotationsPokemonToDelete addObject:pokemon.spawnpoint];
                PokemonAnnotation *point = [[PokemonAnnotation alloc] initWithPokemon:pokemon andLocalization:self.localization];
                [self.annotationsToAdd addObject:point];
                
            } else if ([anObject isKindOfClass:[Gym class]]) {
                Gym *gym = (Gym *)anObject;
                [self.annotationsGymsToDelete addObject:gym.identifier];
                GymAnnotation *point = [[GymAnnotation alloc] initWithGym:gym];
                [self.annotationsToAdd addObject:point];
                
                
            } else if ([anObject isKindOfClass:[PokeStop class]]) {
                PokeStop *pokeStop = (PokeStop *)anObject;
                [self.annotationsPokeStopsToDelete addObject:pokeStop.identifier];
                PokestopAnnotation *point = [[PokestopAnnotation alloc] initWithPokestop:pokeStop];
                [self.annotationsToAdd addObject:point];
            }
            break;
        }
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSArray *annotations = [self.mapview annotations];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray *gymsToRemove = [annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@ AND self.gymID IN %@" argumentArray:@[[GymAnnotation class], self.annotationsGymsToDelete]]];
        NSArray *pokestopsToRemove = [annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@ AND self.pokestopID IN %@" argumentArray:@[[PokestopAnnotation class], self.annotationsPokeStopsToDelete]]];
        NSArray *pokemonToRemove = [annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@ AND self.spawnpointID IN %@" argumentArray:@[[PokemonAnnotation class], self.annotationsPokemonToDelete]]];
        
        //make sure we're on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapview removeAnnotations:gymsToRemove];
            [self.mapview removeAnnotations:pokestopsToRemove];
            [self.mapview removeAnnotations:pokemonToRemove];
            [self.mapview addAnnotations:self.annotationsToAdd];
            
            [self.annotationsToAdd removeAllObjects];
            [self.annotationsPokeStopsToDelete removeAllObjects];
            [self.annotationsPokemonToDelete removeAllObjects];
            [self.annotationsGymsToDelete removeAllObjects];
        });
    });}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.annotationsToAdd = [[NSMutableArray alloc] init];
    self.annotationsPokemonToDelete = [[NSMutableArray alloc] init];
    self.annotationsGymsToDelete = [[NSMutableArray alloc] init];
    self.annotationsPokeStopsToDelete = [[NSMutableArray alloc] init];
}

#pragma mark - Fetch Results Controller setup

- (NSFetchedResultsController *)newPokemonFetchResultsControllersForCurrentPreferences
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_pokemons"]) {
        NSArray *favorites = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_favorite"] valueForKey:@"intValue"];
        if (!favorites) {
            favorites = @[];
        }
        NSArray *common = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pokemon_common"] valueForKey:@"intValue"];
        if (!common) {
            common = @[];
        }
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pokemon"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"encounter" ascending:YES]]];
        request.fetchBatchSize = 50;
        NSMutableArray *predicates = [[NSMutableArray alloc] init];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_onlyfav"]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"identifier IN %@" argumentArray:@[favorites]]];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_common"]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"NOT (identifier IN %@)" argumentArray:@[common]]];
        }
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataPersistance sharedInstance].uiContext sectionNameKeyPath:nil cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) {
            NSLog(@"Error performing fetch request for pokemon listing: %@", error);
        }
        
        return frc;
    }
    
    return nil;
}

- (NSFetchedResultsController *)newGymFetchResultsControllersForCurrentPreferences
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_gyms"]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Gym"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
        request.fetchBatchSize = 50;
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataPersistance sharedInstance].uiContext sectionNameKeyPath:nil cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) {
            NSLog(@"Error performing fetch request for gym listing: %@", error);
        }
        
        return frc;
    }
    return nil;
}

- (NSFetchedResultsController *)newPokestopFetchResultsControllersForCurrentPreferences
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_pokestops"]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PokeStop"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
        request.fetchBatchSize = 50;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_onlylured"]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lureExpiration != nil"];
            [request setPredicate:predicate];
        }
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataPersistance sharedInstance].uiContext sectionNameKeyPath:nil cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) {
            NSLog(@"Error performing fetch request for pokestop listing: %@", error);
        }
        
        return frc;
    }
    return nil;
}

- (void)reloadMap {
    NSLog(@"Reloading map...");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapview removeAnnotations:self.mapview.annotations];
    });
    
    self.pokemonFetchResultController.delegate = nil;
    self.pokemonFetchResultController = [self newPokemonFetchResultsControllersForCurrentPreferences];
    self.gymFetchResultController.delegate = nil;
    self.gymFetchResultController = [self newGymFetchResultsControllersForCurrentPreferences];
    self.pokestopFetchResultController.delegate = nil;
    self.pokestopFetchResultController = [self newPokestopFetchResultsControllersForCurrentPreferences];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        if (self.pokemonFetchResultController) {
            for (Pokemon *pokemon in self.pokemonFetchResultController.fetchedObjects) {
                PokemonAnnotation *point = [[PokemonAnnotation alloc] initWithPokemon:pokemon andLocalization:self.localization];
                [annotations addObject:point];
            }
        }
        if (self.gymFetchResultController) {
            for (Gym *gym in self.gymFetchResultController.fetchedObjects) {
                GymAnnotation *point = [[GymAnnotation alloc] initWithGym:gym];
                [annotations addObject:point];
            }
        }
        if (self.pokestopFetchResultController) {
            for (PokeStop *pokeStop in self.pokestopFetchResultController.fetchedObjects) {
                PokestopAnnotation *point = [[PokestopAnnotation alloc] initWithPokestop:pokeStop];
                [annotations addObject:point];
            }
        }
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"radar_lat"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"radar_long"]) {
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_lat"],
                                                                         [[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_long"]);
            
            ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
            dropPin.coordinate = location;
            dropPin.title = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
            [annotations addObject:dropPin];
        }
        
        [self.mapview addAnnotations:annotations];
    });
}

- (void)disconnectUpdates
{
    self.pokemonFetchResultController.delegate = nil;
    self.gymFetchResultController.delegate = nil;
    self.pokestopFetchResultController.delegate = nil;
    self.pokemonFetchResultController = nil;
    self.gymFetchResultController = nil;
    self.pokestopFetchResultController = nil;
}

#pragma mark - Load helpers

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

-(void)loadNavBar
{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_app"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 89, 20)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    
    self.navigationItem.titleView = titleView;
}

#pragma mark - Actions

-(void)locationAction:(id)sender
{
    regionChangeRequested = YES;
    [self checkGPS];
}

-(void)radarAction:(id)sender
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"radar_lat"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"radar_long"]) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_lat"],
                                                                     [[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_long"]);
        [self.mapview setRegion:MKCoordinateRegionMake(location, MKCoordinateSpanMake(MAP_SCALE, MAP_SCALE)) animated:YES];
    }
}

-(void)maptypeAction:(id)sender
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Select the map type", @"The title of an alert that tells the user to select a new type of map")
                                message:NSLocalizedString(@"Please select a mode", @"The message of an alert that tells the user to select a new type of map")
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *standard = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"Standard", @"A button to set standard mode on map")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self.mapview setMapType:(MKMapTypeStandard)];
                             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"map_type_standard"];
                         }];
    UIAlertAction *satelite = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"Satellite", @"A button to set sattelite mode on map")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self.mapview setMapType:(MKMapTypeHybridFlyover)];
                                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"map_type_standard"];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Cancel", @"A button to destroy the alert without saving")
                               style:UIAlertActionStyleCancel
                               handler:nil];
    
    [alert addAction:standard];
    [alert addAction:satelite];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Misc

- (CLLocation *)currentLocation
{
    CLLocation *baseLocation = self.mapview.userLocation.location;
    if (!baseLocation) {
        baseLocation = [[CLLocation alloc] initWithLatitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_lat"] longitude:[[NSUserDefaults standardUserDefaults] doubleForKey:@"radar_long"]];
    }
    return baseLocation;
}

-(void)showAnnotationLocalNotif:(NSNotification *)notification
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude     = [[notification.userInfo objectForKey:@"latitude"] doubleValue];
    coordinate.longitude    = [[notification.userInfo objectForKey:@"longitude"] doubleValue];
    
    [self.mapview setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(MAP_SCALE_ANNOT, MAP_SCALE_ANNOT)) animated:YES];
}

@end
