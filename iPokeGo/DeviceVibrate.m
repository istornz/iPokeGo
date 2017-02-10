//
//  DeviceVibrate.m
//  iPokeGo
//
//  Created by Joshua Luongo on 25/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "DeviceVibrate.h"

@import AudioToolbox;

@implementation DeviceVibrate

+ (void)hapticVibrate {
    NSDictionary *vibrationParameters = @{@"VibePattern": @[@YES, @50], @"Intensity": @0.5};
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-function-declaration"
    AudioServicesStopSystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, vibrationParameters);
#pragma clang diagnostic pop
}

+ (void)standardVibrate {
    AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil);
}

@end
