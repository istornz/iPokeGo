//
//  ViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PokemonAnnotation.h"
#import "PokemonView.h"
#import "global.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKCoordinateRegion region;
    BOOL moved;
}

@property(weak, nonatomic) IBOutlet UIButton *locationButton;
@property(nonatomic, retain) IBOutlet MKMapView *mapview;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property(strong, nonatomic) NSString *requestStr;
@property(strong, nonatomic) NSString *display_pokemons_str;
@property(strong, nonatomic) NSString *display_pokestops_str;
@property(strong, nonatomic) NSString *display_gyms_str;
@property(strong, nonatomic) NSTimer *timerData;

-(IBAction)locationAction:(id)sender;

@end

