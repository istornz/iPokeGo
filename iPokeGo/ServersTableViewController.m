//
//  ServersTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 04/09/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "ServersTableViewController.h"

@interface ServersTableViewController ()

@end

@implementation ServersTableViewController

NSString *server_name_prefs;
NSString *server_addr_prefs;
NSString *server_type_prefs;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serversPogomArray          = [[NSMutableArray alloc] init];
    self.serversPokemonGoMapArray   = [[NSMutableArray alloc] init];

    [self loadCurrentServer];
}

-(void)loadCurrentServer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    server_name_prefs = [defaults objectForKey:@"server_name"];
    server_addr_prefs = [defaults objectForKey:@"server_addr"];
    server_type_prefs = [defaults objectForKey:@"server_type"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshServersList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshServersList
{
    self.serversArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
    
    [self.serversPokemonGoMapArray removeAllObjects];
    [self.serversPogomArray removeAllObjects];
    
    for (int i = 0; i < [self.serversArray count]; i++) {
        if([self.serversArray[i][@"server_type"] intValue] == POKEMONGOMAP_TYPE)
        {
            [self.serversPokemonGoMapArray addObject:self.serversArray[i]];
        }
        else
        {
            [self.serversPogomArray addObject:self.serversArray[i]];
        }
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger row = 0;
    switch (section) {
        case 0:
            row = [self.serversPokemonGoMapArray count];
            break;
        case 1:
            row = [self.serversPogomArray count];
            break;
    }
    
    return row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && [self.serversPokemonGoMapArray count] > 0)
        return @"PokemonGO-Map";
    else if (section == 1 && [self.serversPogomArray count] > 0)
        return @"Pogom";
    
    if([self.serversPokemonGoMapArray count] == 0 && [self.serversPogomArray count] == 0)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = NSLocalizedString(@"No server", nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.backgroundView = nil;
    }
        
    return nil;
}

#pragma mark - Actions

-(IBAction)addAction:(id)sender {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellServer" forIndexPath:indexPath];
    
    NSString *server_type;
    
    if(indexPath.section == POKEMONGOMAP_TYPE)
    {
        cell.serverNameLabel.text = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_name"];
        cell.serverAddrLabel.text = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_addr"];
        server_type               = SERVER_API_DATA_POKEMONGOMAP;
    }
    else
    {
        cell.serverNameLabel.text = [self.serversPogomArray[indexPath.row] objectForKey:@"server_name"];
        cell.serverAddrLabel.text = [self.serversPogomArray[indexPath.row] objectForKey:@"server_addr"];
        server_type               = SERVER_API_DATA_POGOM;
    }
    
    if(([cell.serverNameLabel.text isEqualToString:server_name_prefs]) && ([cell.serverAddrLabel.text isEqualToString:server_addr_prefs]) && ([server_type_prefs isEqualToString:server_type]))
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *server_name;
    NSString *server_user;
    NSString *server_addr;
    NSString *server_pass;
    NSInteger server_type;
    
    if(indexPath.section == POKEMONGOMAP_TYPE)
    {
        server_name = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_name"];
        server_addr = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_addr"];
        server_user = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_username"];
        server_pass = [self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_password"];
        server_type = [[self.serversPokemonGoMapArray[indexPath.row] objectForKey:@"server_type"] intValue];
    }
    else
    {
        server_name = [self.serversPogomArray[indexPath.row] objectForKey:@"server_name"];
        server_addr = [self.serversPogomArray[indexPath.row] objectForKey:@"server_addr"];
        server_user = [self.serversPogomArray[indexPath.row] objectForKey:@"server_username"];
        server_pass = [self.serversPogomArray[indexPath.row] objectForKey:@"server_password"];
        server_type = [[self.serversPogomArray[indexPath.row] objectForKey:@"server_type"] intValue];
    }
    
    if([server_name length] > 0)
        [prefs setObject:server_name forKey:@"server_name"];
    
    if([server_user length] > 0)
        [prefs setObject:server_user forKey:@"server_user"];
    
    if([server_pass length] > 0)
        [prefs setObject:server_pass forKey:@"server_pass"];
    
    if([server_addr length] > 0)
        [prefs setObject:server_addr forKey:@"server_addr"];
    
    if (server_type == POKEMONGOMAP_TYPE)
        [prefs setObject:SERVER_API_DATA_POKEMONGOMAP forKey:@"server_type"];
    else
        [prefs setObject:SERVER_API_DATA_POGOM forKey:@"server_type"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if(indexPath.section == POKEMONGOMAP_TYPE)
            [self.serversPokemonGoMapArray removeObjectAtIndex:indexPath.row];
        else
            [self.serversPogomArray removeObjectAtIndex:indexPath.row];
        
        [self rebuildServerList];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)rebuildServerList
{
    NSArray *server_list = [self.serversPokemonGoMapArray arrayByAddingObjectsFromArray:self.serversPogomArray];
    
    [[NSUserDefaults standardUserDefaults] setObject:server_list forKey:@"servers"];
}

@end
