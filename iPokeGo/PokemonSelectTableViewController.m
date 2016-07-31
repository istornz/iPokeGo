//
//  FavoriteTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 23/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonSelectTableViewController.h"

@interface PokemonSelectTableViewController ()

@property(strong, nonatomic) NSMutableArray *pokemonID;
@property(strong, nonatomic) NSMutableArray *pokemonSelected;
@property(strong, nonatomic) NSDictionary *localization;

@end

@implementation PokemonSelectTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        [self loadLocalization];
        self.pokemonID = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.localization.count; i++) {
            [self.pokemonID addObject:@(i)];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.pokemonSelected = [NSMutableArray arrayWithArray:[defaults objectForKey:self.preferenceKey]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pokemonID count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *pokemonID = [NSString stringWithFormat:@"%@", @(indexPath.row + 1)];
    PokemonTableViewCell *cell      = [tableView dequeueReusableCellWithIdentifier:@"pokemoncell" forIndexPath:indexPath];
    NSString *key                   = [NSString stringWithFormat:@"%d", ((int)indexPath.row + 1)];
    
    cell.pokemonName.text           = [self.localization objectForKey:[NSString stringWithFormat:@"%@", key]];

    UIImage *largeImage = [UIImage imageNamed : @"icons-hd.png"];
    
    /* Spritesheet has 7 columns */
    int x = indexPath.row%SPRITESHEET_COLS*SPRITE_SIZE;
    
    int y = (int)indexPath.row + 1;
    
    while(y%SPRITESHEET_COLS != 0) y++;
    
    y = ((y/SPRITESHEET_COLS) -1) * SPRITE_SIZE;
    
    CGRect cropRect = CGRectMake(x, y, SPRITE_SIZE, SPRITE_SIZE);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
    cell.pokemonimageView.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if ([self.pokemonSelected containsObject:pokemonID]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *pokemonID = [NSString stringWithFormat:@"%@", @(indexPath.row + 1)];
    PokemonTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.pokemonSelected containsObject:pokemonID]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [self.pokemonSelected removeObject:pokemonID];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.pokemonSelected addObject:pokemonID];
    }
}

-(void)loadLocalization
{
    NSError *error;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"pokemon" withExtension:@"json"];
    
    self.localization = [[NSDictionary alloc] init];

    NSString *stringPath = [filePath absoluteString];
    NSData *localizationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    self.localization = [NSJSONSerialization JSONObjectWithData:localizationData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
}

-(IBAction)saveAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:self.pokemonSelected forKey:self.preferenceKey];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
