//
//  SpriteSplitter.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/31/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "SpriteSplitter.h"
@import UIKit;

@implementation SpriteSplitter

#define SPRITESHEET_COLS    7
#define SPRITE_SIZE         65
#define IMAGE_SIZE          45

+ (void)splitSpritesOnImageNamed:(NSString *)image
{
    UIImage *largeImage = [UIImage imageNamed : image];
    CGImageRef spriteSheet = [largeImage CGImage];
    
    for (int scale = 1; scale <= 3; scale++) {
        CGSize size = CGSizeMake(IMAGE_SIZE * scale, IMAGE_SIZE * scale);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        for (int pokemonID = 1; pokemonID <= 151; pokemonID++) {
            /* Spritesheet has 7 columns */
            int x = (pokemonID - 1)%SPRITESHEET_COLS*SPRITE_SIZE;
            int y = pokemonID;
            
            while(y%SPRITESHEET_COLS != 0) y++;
            y = (y/SPRITESHEET_COLS - 1) * SPRITE_SIZE;
            CGRect cropRect = CGRectMake(x, y, SPRITE_SIZE, SPRITE_SIZE);
            CGImageRef imageRef = CGImageCreateWithImageInRect(spriteSheet, cropRect);
            CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            CGImageRelease(imageRef);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"Pokemon_%@@%@x.png", @(pokemonID), @(scale)]];
            NSData *dataForImage = UIImagePNGRepresentation(newImage);
            NSError *error;
            if (![dataForImage writeToFile:filePath options:NSDataWritingAtomic error:&error]) {
                NSLog(@"Error saving image: %@", error);
            }
        }
        UIGraphicsEndImageContext();
    }
}

@end
