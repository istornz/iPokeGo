//
//  SpawnPointsAnnotationView.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 16/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SpawnPointsAnnotationView.h"

@implementation SpawnPointsAnnotationView

- (instancetype)initWithAnnotation:(SpawnPointsAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = NO;
        self.image = [UIImage imageNamed:@"spawnpoint"];
        self.frame = CGRectMake(0, 0, 5, 5);
        
    }
    
    return self;
}

@end
