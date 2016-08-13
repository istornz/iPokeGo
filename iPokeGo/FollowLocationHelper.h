//
//  FollowLocationHelper.h
//  iPokeGo
//
//  Created by David on 12/8/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FollowLocationHelper: NSObject

- (void)updateLocation:(CLLocation *)location;
- (BOOL)mustUpdateLocation:(CLLocation *)location;

@end
