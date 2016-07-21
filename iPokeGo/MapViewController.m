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
    
    self.mapview.zoomEnabled = true;
    moved = NO;
    
    [self checkGPS];
    self.requestStr = [self buildRequest];
    
    if(self.requestStr != nil)
    {
        self.timerData = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(loadData)
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

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(PokemonView *)view
{
    
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
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    [self.mapview removeAnnotations:self.mapview.annotations];
    /*************************************/
    //           Requête POST            //
    /*************************************/
#pragma mark Requête POST
    //self.requestStr
    NSURL *url = [NSURL URLWithString:@"http://raspberrypi.home/dev/projet_pokemongo/data.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
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
                                       NSArray *pokemons = jsonData[@"pokemons"];
                                       
                                       for (int i = 0; i < [pokemons count]; i++) {
                                           PokemonAnnotation *point = [[PokemonAnnotation alloc] init];
                                           CLLocationCoordinate2D pokemonLocation = CLLocationCoordinate2DMake([pokemons[i][@"latitude"] floatValue], [pokemons[i][@"longitude"] floatValue]);
                                           
                                           point.coordinate = pokemonLocation;
                                           point.title      = [pokemons[i] valueForKey:@"pokemon_name"];
                                           point.subtitle   = [NSString stringWithFormat:@"%d", [[pokemons[i] valueForKey:@"pokemon_id"] intValue]];
                                           point.pokemonID  = [[pokemons[i] valueForKey:@"pokemon_id"] intValue];
                                           
                                           [self.mapview addAnnotation:point];
                                       }
                                   }
                                   
                                   if([self.display_pokestops_str isEqualToString:@"true"])
                                   {
                                       NSArray *pokestops = jsonData[@"pokestops"];
                                       
                                       for (int i = 0; i < [pokestops count]; i++) {
                                           
                                       }
                                   }
                                   
                                   if([self.display_gyms_str isEqualToString:@"true"])
                                   {
                                       NSArray *gyms = jsonData[@"gyms"];
                                       
                                       for (int i = 0; i < [gyms count]; i++) {
                                           
                                       }
                                   }
                                   
                               }
                               
                           }];
    
    //});
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

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(PokemonAnnotation *)annotation {
    
    MKAnnotationView *view = nil;
    if ((id<MKAnnotation>)annotation != mapView.userLocation) {
        
        view = [mapView dequeueReusableAnnotationViewWithIdentifier:[NSString stringWithFormat:@"%d",annotation.pokemonID]];
        if (!view) {
            
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[NSString stringWithFormat:@"%d",annotation.pokemonID]];
            
            view.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", annotation.pokemonID]];
        }
    }
    return view;
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!moved)
    {
        [self.mapview setCenterCoordinate:userLocation.location.coordinate animated:YES];
        moved = YES;
    }
}

-(void)locationAction:(id)sender
{
    region.center = self.mapview.userLocation.coordinate;
    region.span.latitudeDelta   = MAP_SCALE;
    region.span.longitudeDelta  = MAP_SCALE;
    [self.mapview setRegion:region animated:YES];
}

@end
