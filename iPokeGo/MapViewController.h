//
//  ViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 21/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "CWStatusBarNotification.h"
#import "PokemonAnnotation.h"
#import "GymAnnotation.h"
#import "PokestopAnnotation.h"
#import "ScanAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "global.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPopoverControllerDelegate>
{
    MKCoordinateRegion region;
    AVAudioPlayer *pokemonAppearSound;
    AVAudioPlayer *pokemonFavAppearSound;
    CLLocationCoordinate2D radar;
    BOOL firstConnection;
    BOOL moved;
    BOOL isFav;
    
    BOOL isNormalNotificationActivated;
    BOOL isFavNotificationActivated;
    BOOL isHideVeryCommonActivated;
}

@property(weak, nonatomic) IBOutlet UIButton *locationButton;
@property(weak, nonatomic) IBOutlet UIButton *radarButton;
@property(nonatomic, retain) IBOutlet MKMapView *mapview;

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(strong, nonatomic) NSString *requestStr;
@property(strong, nonatomic) NSString *requestNewLocationStr;
@property(strong, nonatomic) NSString *display_pokemons_str;
@property(strong, nonatomic) NSString *display_pokestops_str;
@property(strong, nonatomic) NSString *display_gyms_str;
@property(strong, nonatomic) NSTimer *timerData;
@property(strong, nonatomic) NSTimer *timerDataCleaner;

@property(strong, nonatomic) NSMutableArray *pokemons;
@property(strong, nonatomic) NSMutableArray *pokestops;
@property(strong, nonatomic) NSMutableArray *gyms;
@property(strong, nonatomic) NSArray *savedFavorite;
@property(strong, nonatomic) NSArray *savedCommon;

@property(strong, nonatomic) NSDictionary *localization;
@property(strong, nonatomic) NSDictionary *mapLocation;

@property(strong, nonatomic) UIPopoverController *popover;
@property(strong, nonatomic) CWStatusBarNotification *notification;


-(IBAction)locationAction:(id)sender;
-(IBAction)radarAction:(id)sender;

@end

