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
#import "CoreDataPersistance.h"
#import "CoreDataEntities.h"
#import "SettingsTableViewController.h"
#import "iPokeServerSync.h"
#import <AudioToolbox/AudioServices.h>
@import CoreData;

@interface MapViewController() <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *gymFetchResultController;
@property NSFetchedResultsController *pokemonFetchResultController;
@property NSFetchedResultsController *pokestopFetchResultController;

@property NSMutableArray *annotationsToAdd;
@property NSMutableArray *annotationsPokemonToDelete;
@property NSMutableArray *annotationsGymsToDelete;
@property NSMutableArray *annotationsPokeStopsToDelete;

@property CLLocationManager *locationManager;
@property NSArray *animatedPokestopLured;
@property NSDictionary *localization;
@property (weak, nonatomic) IBOutlet UISwitch *searchControlToggleSwitch;

@end

@implementation MapViewController

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
    
    [self loadNavBar];
    [self loadAnimatedImages];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapview addGestureRecognizer:longPressGesture];
    
    //default to the last known position
    NSDictionary *mapLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"map_position"];
    if([mapLocation count] > 0) {
        MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake([[mapLocation objectForKey:@"latitude"] doubleValue],
                                                                                      [[mapLocation objectForKey:@"longitude"] doubleValue]),
                                                           MKCoordinateSpanMake([[mapLocation objectForKey:@"latitudeDelta"] doubleValue],
                                                                                [[mapLocation objectForKey:@"longitudeDelta"] doubleValue]));
        
        [self.mapview setRegion:region animated:NO];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverStatusRefreshed:) name:SERVER_SEARCH_STAT object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadMap];
    [self checkGPS];
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
    iPokeServerSync *server = [[iPokeServerSync alloc] init];
    [server callSearchControlValue];
    
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

#pragma mark - Gesture recognizers

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        CGPoint point = [sender locationInView:self.mapview];
        CLLocationCoordinate2D location = [self.mapview convertPoint:point toCoordinateFromView:self.mapview];
        
        ScanAnnotation *dropPin = [[ScanAnnotation alloc] init];
        dropPin.coordinate = location;
        dropPin.title = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
        
        for (int i = 0; i < [self.mapview.annotations count]; i++) {
            MKPointAnnotation *annotation = (MKPointAnnotation *)self.mapview.annotations[i];
            if([self.mapview.annotations[i] isKindOfClass:[ScanAnnotation class]])
                [self.mapview removeAnnotation:annotation];
        }
        [self.mapview addAnnotation:dropPin];
        
        iPokeServerSync *server = [[iPokeServerSync alloc] init];
        [server setLocation:location];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.latitude] forKey:@"radar_lat"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:location.longitude] forKey:@"radar_long"];
    }
}

#pragma mark - Mapview delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSArray *annotations = self.mapview.annotations;
    for (int i = 0; i < [annotations count]; i++) {
        id<MKAnnotation> annotation = (MKPointAnnotation *)[annotations objectAtIndex:i];
        if (self.mapview.region.span.latitudeDelta > .20) {
            if([annotation isKindOfClass:[PokemonAnnotation class]] || [annotation isKindOfClass:[GymAnnotation class]] || [annotation isKindOfClass:[PokestopAnnotation class]]) {
                [[self.mapview viewForAnnotation:annotation] setHidden:YES];
            }
        } else {
            [[self.mapview viewForAnnotation:annotation] setHidden:NO];
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *mapRegion = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithDouble:self.mapview.region.center.latitude], [NSNumber numberWithDouble:self.mapview.region.center.longitude], [NSNumber numberWithDouble:self.mapview.region.span.latitudeDelta], [NSNumber numberWithDouble:self.mapview.region.span.longitudeDelta]] forKeys:@[@"latitude", @"longitude", @"latitudeDelta", @"longitudeDelta"]];
    
    [prefs setObject:mapRegion forKey:@"map_position"];
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *view = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ((id<MKAnnotation>)annotation != mapView.userLocation) {
        if([annotation isKindOfClass:[PokemonAnnotation class]])
        {
            PokemonAnnotation *annotationPokemon = annotation;
            NSString *reuse = [NSString stringWithFormat:@"pokemon_%@", @(annotationPokemon.pokemonID)];
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
            
            if (!view) {
                
                UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *btnImage   = [UIImage imageNamed:@"drive"];
                button.frame = CGRectMake(0, 0, 30, 30);
                [button setImage:btnImage forState:UIControlStateNormal];
                
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
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
            view.hidden = self.mapview.region.span.latitudeDelta >= .20;
        }
        else if ([annotation isKindOfClass:[GymAnnotation class]])
        {
            GymAnnotation *annotationGym = annotation;
            NSString *reuse = [NSString stringWithFormat:@"gym_%@", @(annotationGym.teamID)];
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
            if (!view) {
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
                view.canShowCallout = YES;
                UIImage *gymImage = [UIImage imageNamed:@"Gym.png"];
                
                switch (annotationGym.teamID) {
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
            view.hidden = self.mapview.region.span.latitudeDelta >= .20;
        }
        else if ([annotation isKindOfClass:[PokestopAnnotation class]])
        {
            PokestopAnnotation *annotationPokestop = annotation;
            NSString *reuse = annotationPokestop.hasLure ? @"pokestop" : @"pokestop_lured";
            view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuse];
            
            if (!view) {
                view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuse];
                view.canShowCallout = YES;
                
                UIImage *pokestopImage = [UIImage imageNamed:@"Pstop.png"];
                
                if(annotationPokestop.hasLure)
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
            view.hidden = self.mapview.region.span.latitudeDelta >= .20;
        }
        else if ([annotation isKindOfClass:[ScanAnnotation class]])
        {
            SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"scan"];
            if (!view) {
                pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"scan"];
                pulsingView.canShowCallout = YES;
                
                CGPoint point = view.center;
                point.x = (point.x + 20);
                point.y = (point.y + 20);
                
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
    MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:endingCoord addressDictionary:nil];
    MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    
    NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    
    [endingItem openInMapsWithLaunchOptions:launchOptions];
}

#pragma mark - CLLocationManager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    for (CLLocation *location in locations) {
        //make sure it is reasonably fresh, say the last 30 seconds
        if ([location.timestamp timeIntervalSinceNow] > -30) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(MAP_SCALE, MAP_SCALE));
                [self.mapview setRegion:region animated:YES];
            });
            [self.locationManager stopUpdatingLocation];
            break;
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
}

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
    
    UIImage* image = [UIImage imageNamed:@"logo_app.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect frame = CGRectMake(0, 0, 90, 20);
    imageView.frame = frame;
    
    UIView* titleView = [[UIView alloc] initWithFrame:imageView.frame];
    [titleView addSubview:imageView];
    
    self.navigationItem.titleView = titleView;
}

-(void)loadAnimatedImages
{
    self.animatedPokestopLured = @[[UIImage imageNamed:@"Pokespot-Lured_0023_Frame-1.png"],
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
                                   [UIImage imageNamed:@"Pokespot-Lured_0000_Frame-24.png"]];
}

#pragma mark - Actions

-(void)locationAction:(id)sender
{
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

- (IBAction)searchControlToggled:(UISwitch *)sender {
    NSString* searchControlValue = @"on";
    
    if (!sender.isOn) {
        searchControlValue = @"off";
    }
    iPokeServerSync *server = [[iPokeServerSync alloc] init];
    [server setSearchControl:searchControlValue];
}

- (void) serverStatusRefreshed:(NSNotification*)notif {
    BOOL searchControlEnabled = [[notif.userInfo objectForKey:@"val"] boolValue];
    if (self.searchControlToggleSwitch != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (searchControlEnabled) {
                [self.searchControlToggleSwitch setOn:YES animated:YES];
            } else {
                [self.searchControlToggleSwitch setOn:NO animated:YES];
            }
        });
    }
}

#pragma mark - Misc

- (UILabel*)timeLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    TimeLabel *timeLabel;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"display_timer"]) {
        timeLabel = [[TimerLabel alloc] initWithFrame:CGRectMake(13, -1, 40, 10)];
    } else {
        timeLabel = [[TimeLabel alloc] initWithFrame:CGRectMake(13, -1, 40, 10)];
        
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
    
    DistanceLabel *distanceLabel = [[DistanceLabel alloc] initWithFrame:CGRectMake(-7, 45, 50, 10)];
    [distanceLabel setDistance:distance];
    return distanceLabel;
}

-(void)showAnnotationLocalNotif:(NSNotification *)notification
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude     = [[notification.userInfo objectForKey:@"latitude"] doubleValue];
    coordinate.longitude    = [[notification.userInfo objectForKey:@"longitude"] doubleValue];
    
    [self.mapview setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(MAP_SCALE_ANNOT, MAP_SCALE_ANNOT)) animated:YES];
}

@end
