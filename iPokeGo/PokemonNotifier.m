//
//  PokemonNotifier.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

@import CoreData;
#import "PokemonNotifier.h"
#import "CoreDataEntities.h"
#import "MapViewController.h"
#import "CoreDataPersistance.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import "CWStatusBarNotification.h"

@interface PokemonNotifier() <NSFetchedResultsControllerDelegate>

@property NSFetchedResultsController *pokemonFetchResultsController;
@property AVAudioPlayer *pokemonAppearSound;
@property AVAudioPlayer *pokemonFavAppearSound;

@end

@implementation PokemonNotifier

- (instancetype)init {
    if (self = [super init]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Pokemon"];
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"encounter" ascending:YES]]];
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[CoreDataPersistance sharedInstance].uiContext sectionNameKeyPath:nil cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) {
            NSLog(@"Error performing fetch request for pokemon notification listener: %@", error);
        }
        self.pokemonFetchResultsController = frc;
        
        NSString *pathPokemonAppearSound    = [NSString stringWithFormat:@"%@/ding.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *soundUrlPokemonAppearSound   = [NSURL fileURLWithPath:pathPokemonAppearSound];
        
        NSString *pathPokemonFavAppearSound    = [NSString stringWithFormat:@"%@/favoritePokemon.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *soundUrlPokemonFavAppearSound   = [NSURL fileURLWithPath:pathPokemonFavAppearSound];
        
        AVAudioSession *audiosession = [AVAudioSession sharedInstance];
        [audiosession setCategory:AVAudioSessionCategoryAmbient error:nil];
        
        self.pokemonAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonAppearSound error:nil];
        self.pokemonFavAppearSound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrlPokemonFavAppearSound error:nil];
    }
    return self;
}

-(void)displayNotificationForPokemon:(Pokemon *)pokemon
{
    NSString *message   = nil;
    AVAudioPlayer *sound = nil;
    
    if([pokemon isFav]) {
        message = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] your favorite pokemon was added to the map!", @"The hint that a favorite Pokémon appeared on the map.") , [self.mapViewController.localization objectForKey:[NSString stringWithFormat:@"%d", pokemon.identifier]]];
        sound   = self.pokemonAppearSound;
    } else {
        message = [NSString localizedStringWithFormat:NSLocalizedString(@"[Pokemon] was added to the map!", @"The hint that a certain Pokémon appeared on the map.") , [self.mapViewController.localization objectForKey:[NSString stringWithFormat:@"%d", pokemon.identifier]]];
        sound   = self.pokemonAppearSound;
    }
    
    //pre iOS 10 notifications aren't shown when the app is active, so only show them in BG
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:@[@(pokemon.location.latitude), @(pokemon.location.longitude)] forKeys:@[@"latitude", @"longitude"]];
        
        UILocalNotification *localN         = [[UILocalNotification alloc] init];
        localN.fireDate                     = [NSDate date];
        localN.alertBody                    = message;
        localN.timeZone                     = [NSTimeZone defaultTimeZone];
        localN.soundName                    = sound.url.lastPathComponent;
        localN.userInfo                     = infoDict;
        localN.applicationIconBadgeNumber   = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localN];
        
    //if app is active use the status bar overlay
    } else {
        CWStatusBarNotification *notification = [CWStatusBarNotification new];
        if ([pokemon isFav]) {
            notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
            notification.notificationLabelTextColor = [UIColor whiteColor];
        }
        [sound play];
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"vibration"]) {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        }
        
        [notification displayNotificationWithMessage:message forDuration:4.5f];
        notification.notificationTappedBlock = ^(void) {
            [self.mapViewController.mapview setCenterCoordinate:pokemon.location animated:YES];
        };
    }
}

#pragma mark - FRC Delegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            if ([anObject isKindOfClass:[Pokemon class]]) {
                Pokemon *pokemon = (Pokemon *)anObject;
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"fav_notification"] && [pokemon isFav]) {
                    [self displayNotificationForPokemon:pokemon];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"norm_notification"]) {
                    [self displayNotificationForPokemon:pokemon];
                }
                
            }
            break;
        }
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
}

@end
