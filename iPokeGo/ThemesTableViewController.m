//
//  ThemesTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 26/02/2017.
//  Copyright © 2017 Dimitri Dessus. All rights reserved.
//

#import "ThemesTableViewController.h"

@interface ThemesTableViewController ()

@end

@implementation ThemesTableViewController {
    UIRefreshControl *refreshControl;
    M13ProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadThemes) forControlEvents:UIControlEventValueChanged];
    
    [self loadProgressView];
    [self loadThemes];
}

-(void)loadProgressView {
    HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    HUD.progressViewSize = CGSizeMake(60.0, 60.0);
    HUD.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    HUD.primaryColor = [UIColor whiteColor];
    HUD.secondaryColor = [UIColor whiteColor];
    
    UIWindow *window = ((AppDelegate *)[UIApplication safeM13SharedApplication].delegate).window;
    [window addSubview:HUD];
}

-(void)loadThemes {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *themeInstalled = [defaults objectForKey:@"themeInstalled"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSMutableArray *themeFound = [[NSMutableArray alloc] init];
    
    NSString *selected = @"0";
    if([themeInstalled[@"id"] isEqualToString:@"default_theme"]) {
        selected = @"1";
    }
    
    if([themeInstalled count] == 0) {
        selected = @"1";
    }
    
    NSDictionary *defaultTheme = [[NSDictionary alloc] initWithObjects:@[@"default_theme", @"Default theme", @"Default theme with Pokemon label", @"", @"default_theme", selected] forKeys:@[@"id", @"name", @"short_description", @"dir", @"image", @"selected"]];
    [themeFound addObject:defaultTheme];
    
    for (NSString *dir in fileList){
        if([dir containsString:@"theme_"] && ![dir containsString:@".zip"] ) {
            NSDictionary *jsonDataArray = [self getMetaDataFromThemePackage:dir];
            NSString *selected = @"0";
            
            if([jsonDataArray[@"id"] isEqualToString:themeInstalled[@"id"]]) {
                selected = @"1";
            }
            
            NSDictionary *themeDict = [[NSDictionary alloc] initWithObjects:@[jsonDataArray[@"id"], jsonDataArray[@"name"], jsonDataArray[@"short_description"], dir, [NSString stringWithFormat:@"%@/%@/icon.png", documentsDirectory, dir], selected] forKeys:@[@"id", @"name", @"short_description", @"dir", @"image", @"selected"]];
            
            [themeFound addObject:themeDict];
        }
    }
    
    self.themeArray = [[NSArray alloc] initWithArray:themeFound];
    self.footerLabel.text = [NSString stringWithFormat:@"%d theme(s) installed", (int)[self.themeArray count]];
    [refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(NSDictionary *)getMetaDataFromThemePackage:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/meta.json", file]];
    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    NSDictionary *jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    return jsonDataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.themeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThemesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [self.themeArray[indexPath.row] objectForKey:@"name"];
    cell.describeLabel.text = [self.themeArray[indexPath.row] objectForKey:@"short_description"];
    
    if(indexPath.row > 0) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"file://%@", [self.themeArray[indexPath.row] objectForKey:@"image"]]];
        
        cell.themeIconImageView.image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ThemesTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell)
                            cell.themeIconImageView.image = image;
                    });
                }
            }
        }];
        
        [task resume];
    } else {
        cell.themeIconImageView.image = [UIImage imageNamed:[self.themeArray[indexPath.row] objectForKey:@"image"]];
    }
    
    if([self.themeArray[indexPath.row][@"selected"] isEqualToString:@"1"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Installation"
                                message:[NSString stringWithFormat:@"Do you really want to install the theme '%@' ?", [self.themeArray[indexPath.row] objectForKey:@"name"]]
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             [self installThemePosition:indexPath];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)downloadNewThemeAction:(id)sender {
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:@"Download theme" message:@"Please enter the URL of your theme (must be a direct link on the .zip archive)" preferredStyle:UIAlertControllerStyleAlert];
    [alerController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"http://adress.com/theme_name.zip";
        textField.text = @"http://";
        textField.keyboardType = UIKeyboardTypeURL;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *urlStr = [[alerController textFields][0] text];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        if([urlStr containsString:@".zip"]) {
            [self downloadFileWithURL:url];
        } else {
            UIAlertController *alert2 = [UIAlertController
                                         alertControllerWithTitle:@"Error"
                                         message:@"Check your url, it should point on a .zip file directly !"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok2 = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [alert2 dismissViewControllerAnimated:YES completion:nil];
                                  }];
            
            [alert2 addAction:ok2];
            
            [self presentViewController:alert2 animated:YES completion:nil];
        }
        
    }];
    
    [alerController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canceled");
    }];
    
    [alerController addAction:cancelAction];
    [self presentViewController:alerController animated:YES completion:nil];
}

-(void)downloadFileWithURL:(NSURL *)url {
    
    HUD.status = @"Downloading...";
    [HUD show:YES];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            [HUD setProgress:downloadProgress.fractionCompleted animated:YES];
        });
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        [self processingDownloadedFile:filePath];
    }];
    
    [downloadTask resume];
}

-(void)processingDownloadedFile:(NSURL *)filePath {
    
    NSString *filePathStr = [filePath.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSString *destinationPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    HUD.status = @"Decompressing...";
    [HUD setIndeterminate:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:filePathStr toDestination:destinationPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(cleanUp:) withObject:filePathStr afterDelay:1.5];
        });
    });
}

-(void)cleanUp:(NSString *)filePath {
    
    HUD.status = @"Cleaning up...";
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
    
    [self performSelector:@selector(setComplete) withObject:nil afterDelay:1.5];
}

- (void)setComplete
{
    HUD.status = @"Complete !";
    [HUD setIndeterminate:NO];
    [HUD performAction:M13ProgressViewActionSuccess animated:YES];
    [self performSelector:@selector(resetProgressRing) withObject:nil afterDelay:1.5];
}

- (void)resetProgressRing
{
    [HUD hide:YES];
    [HUD performAction:M13ProgressViewActionNone animated:NO];
    [self loadThemes];
}

-(void)installThemePosition:(NSIndexPath *)indexPath {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.themeArray[indexPath.row] forKey:@"themeInstalled"];
    [prefs synchronize];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Installation complete"
                                message:@"Please re-launch the app by killing it to apply the change !"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction *action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    NSMutableArray *themeArrayCopy = [self.themeArray mutableCopy];
    
    for (int i = 0; i < [self.themeArray count]; i++) {
        NSMutableDictionary *copyTheme = [[self.themeArray objectAtIndex:i] mutableCopy];
        
        if(indexPath.row == i) {
            [copyTheme setValue:@"1" forKey:@"selected"];
        } else {
            [copyTheme setValue:@"0" forKey:@"selected"];
        }
        
        [themeArrayCopy replaceObjectAtIndex:i withObject:copyTheme];
    }
    
    self.themeArray = [themeArrayCopy copy];
    [self.tableView reloadData];
}

@end
