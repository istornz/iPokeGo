//
//  AddServerTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 04/09/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "AddServerTableViewController.h"

#define CELL_INDEX_SERVERTYPE   0

@interface AddServerTableViewController ()

@end

@implementation AddServerTableViewController

int short server_type = POKEMONGOMAP_TYPE;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.serverTypeLabel.text = @"PokemonGo-Map";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(IBAction)doneAction:(id)sender {
    if([self.serverTextField.text length] > 0 && [self.serverNameField.text length] > 0)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        NSString *server_name = self.serverNameField.text;
        NSString *server_addr = [self.serverTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![server_addr containsString:@"://"] && server_addr.length > 0) {
            server_addr = [NSString stringWithFormat:@"http://%@", server_addr];
            self.serverTextField.text = server_addr;
        }
        
        NSString *server_user = self.usernameField.text;
        NSString *server_pass = self.passwordField.text;
        
        NSDictionary *serverDict = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithInt:server_type], server_name, server_addr, server_user, server_pass] forKeys:@[@"server_type", @"server_name", @"server_addr", @"server_username", @"server_password"]];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[prefs objectForKey:@"servers"]];
        [array addObject:serverDict];
        
        [prefs setObject:array forKey:@"servers"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Error", @"The title of an alert that tells the user there is an error")
                                    message:NSLocalizedString(@"Please check if you have correctly entered server name and url", @"The message of an alert that tells the user to check server name and ip address")
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okbutton = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"OK", @"A button to close the alert")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:okbutton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == CELL_INDEX_SERVERTYPE && indexPath.section == 0)
    {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Select a server type", @"The title of an alert that tells the user to select a server type")
                                    message:NSLocalizedString(@"Please select a type", @"The message of an alert that tells the user to select a new server type")
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *pokemongomap = [UIAlertAction
                                       actionWithTitle:@"PokemonGo-Map"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           self.serverTypeLabel.text = @"PokemonGo-Map";
                                           server_type = POKEMONGOMAP_TYPE;
                                       }];
        UIAlertAction *pogom = [UIAlertAction
                                actionWithTitle:@"Pogom"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    self.serverTypeLabel.text = @"Pogom";
                                    server_type = POGOM_TYPE;
                                }];
        UIAlertAction *cancel = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"Cancel", @"A button to destroy the alert without saving")
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                 }];
        
        [alert addAction:pokemongomap];
        [alert addAction:pogom];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.serverNameField)
        [self.serverTextField becomeFirstResponder];
    else if(textField == self.serverTextField)
        [self.usernameField becomeFirstResponder];
    else if(textField == self.usernameField)
        [self.passwordField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        return NO;
    }
    return YES;
}

@end
