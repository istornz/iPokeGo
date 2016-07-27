//
//  FavoriteTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 23/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonSelectTableViewController.h"

@interface PokemonSelectTableViewController ()

@end

@implementation PokemonSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PokemonTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"pokemoncell"];

    self.pokemonID          = [[NSMutableArray alloc] init];
    self.pokemonChecked     = [[NSMutableArray alloc] init];
    found                   = NO;
    
    [self loadLocalization];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *pokemonListSaved = [defaults objectForKey:self.preferenceKey];
    
    if([pokemonListSaved count] > 0)
        self.pokemonSelected    = [[NSMutableArray alloc] initWithArray:pokemonListSaved];
    else
        self.pokemonSelected    = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < (POKEMON_NUMBER + 1); i++)
    {
        [self.pokemonID addObject:[NSString stringWithFormat:@"%d", i]];
        
        if([pokemonListSaved count] > 0)
        {
            found = NO;
            for (NSString *pokemonIDSaved in pokemonListSaved) {
                if (pokemonIDSaved == [NSString stringWithFormat:@"%d", i]) {
                    found = YES;
                    break;
                }
            }
            
            if(found)
                [self.pokemonChecked addObject:[NSNumber numberWithBool:YES]];
            else
                [self.pokemonChecked addObject:[NSNumber numberWithBool:NO]];
        }
        else
        {
            
            [self.pokemonChecked addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pokemonID count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"pokemoncell";
    PokemonTableViewCell *cell = (PokemonTableViewCell *) [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PokemonTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
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
    
    
    if([[self.pokemonChecked objectAtIndex:indexPath.row] boolValue])
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PokemonTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([[self.pokemonChecked objectAtIndex:indexPath.row] boolValue]) {
        [self.pokemonChecked replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        [self.pokemonSelected removeObject:[self.pokemonID objectAtIndex:indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        [self.pokemonChecked replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        [self.pokemonSelected addObject:[self.pokemonID objectAtIndex:indexPath.row]];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

-(void)loadLocalization
{
    NSString *language = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSError *error;
    
    NSURL *filePath = nil;
    
    self.localization = [[NSDictionary alloc] init];
    
    if([language isEqualToString:@"fr"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.fr" withExtension:@"json"];
    else if([language isEqualToString:@"de"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.de" withExtension:@"json"];
    else if([language isEqualToString:@"en"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.en" withExtension:@"json"];
    else if([language isEqualToString:@"zh_cn"])
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.zh_cn" withExtension:@"json"];
    else
        filePath = [[NSBundle mainBundle] URLForResource:@"pokemon.en" withExtension:@"json"];
    
    NSString *stringPath = [filePath absoluteString];
    NSData *localizationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    self.localization = [NSJSONSerialization JSONObjectWithData:localizationData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
}

-(IBAction)saveAction:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.pokemonSelected forKey:self.preferenceKey];
    [prefs synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
