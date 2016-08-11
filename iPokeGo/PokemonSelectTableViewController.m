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
@property(strong, nonatomic) NSMutableArray *pokemonIDFiltered;
@property(strong, nonatomic) NSMutableArray *pokemonSelected;
@property(strong, nonatomic) NSDictionary *localization;
@property(strong, nonatomic) UISearchController *searchController;

@end

@implementation PokemonSelectTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        [self loadLocalization];
        self.pokemonID = [[NSMutableArray alloc] init];
        self.pokemonIDFiltered = [[NSMutableArray alloc] init];
        for (int i = 1; i <= POKEMON_NUMBER; i++) {
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
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setContentOffset:CGPointMake(0.0, self.searchController.searchBar.frame.size.height) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.active) {
        return [self.pokemonIDFiltered count];
    } else {
        return [self.pokemonID count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *pokemonID;
    if(self.searchController.active) {
        pokemonID = [[self.pokemonIDFiltered objectAtIndex:indexPath.row] stringValue];
    } else {
        pokemonID = [[self.pokemonID objectAtIndex:indexPath.row] stringValue];
    }
    
    PokemonTableViewCell *cell      = [tableView dequeueReusableCellWithIdentifier:@"pokemoncell" forIndexPath:indexPath];
    
    cell.pokemonName.text           = [self.localization objectForKey:pokemonID];

    cell.pokemonimageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%@", pokemonID]];
    
    if ([self.pokemonSelected containsObject:pokemonID]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *pokemonID;
    if(self.searchController.active) {
        pokemonID = [[self.pokemonIDFiltered objectAtIndex:indexPath.row] stringValue];
    } else {
        pokemonID = [[self.pokemonID objectAtIndex:indexPath.row] stringValue];
    }
    
    PokemonTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.pokemonSelected containsObject:pokemonID]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [self.pokemonSelected removeObject:pokemonID];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.pokemonSelected addObject:pokemonID];
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchTerm = searchController.searchBar.text;
    if([searchTerm length] == 0) {
        self.pokemonIDFiltered = [self.pokemonID mutableCopy];
    } else {
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        for(id pokemon in self.pokemonID) {
            if([[self.localization objectForKey:[NSString stringWithFormat:@"%@", pokemon]] containsString:searchTerm]) {
                [searchResults addObject:pokemon];
            }
        }
        
        self.pokemonIDFiltered = searchResults;
    }
    
    [self.tableView reloadData];
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
