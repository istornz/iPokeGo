//
//  NotificationsSettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "NotificationsSettingsTableViewController.h"

#define kCommonRangeCell     1
#define kCommonRangePicker   2
#define kFavoriteRangeCell   4
#define kFavoriteRangePicker 5

@interface NotificationsSettingsTableViewController ()

@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) NSArray *rangePickerRanges;
@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation NotificationsSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.rangePickerRanges = @[@0, @100, @250, @500, @750, @1000, @1500, @2000, @2500, @5000, @10000, @25000];
    self.pickerCellRowHeight = CGRectGetHeight(self.commonRangePicker.frame);
    
    self.commonRangePicker.delegate = self;
    self.commonRangePicker.delegate = self;
    self.commonRangePicker.dataSource = self;
    self.favoriteRangePicker.delegate = self;
    self.favoriteRangePicker.dataSource = self;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.normalNotificationSwitch.on = [prefs boolForKey:@"norm_notification"];
    self.favoriteNotificationSwitch.on = [prefs boolForKey:@"fav_notification"];
    self.vibrationSwitch.on = [prefs boolForKey:@"vibration"];
    self.rangeSwitch.on = [prefs boolForKey:@"only_notify_in_range"];
    
    self.commonRangeLabel.text = [NSString stringWithFormat:@"%dm", (int)[prefs integerForKey:@"common_notification_range"]];
    self.favoriteRangeLabel.text = [NSString stringWithFormat:@"%dm", (int)[prefs integerForKey:@"favorite_notification_range"]];
    
    [self.commonRangePicker selectRow:[self rangePickerRowForValue:(int)[prefs integerForKey:@"common_notification_range"]] inComponent:0 animated:YES];
    [self.favoriteRangePicker selectRow:[self rangePickerRowForValue:(int)[prefs integerForKey:@"favorite_notification_range"]] inComponent:0 animated:YES];
}

-(int)rangePickerRowForValue:(int)value
{
    if(self.rangePickerRanges.count) {
        int index;
        for (index = 0; index <= self.rangePickerRanges.count; index++) {
            if ([[self.rangePickerRanges objectAtIndex:index] intValue] == value) {
                return index;
            }
        }
        
        return 0;
    } else {
        return 0;
    }
}

-(IBAction)switchAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.normalNotificationSwitch) {
        [prefs setBool:self.normalNotificationSwitch.on forKey:@"norm_notification"];
    } else if (sender == self.favoriteNotificationSwitch) {
        [prefs setBool:self.favoriteNotificationSwitch.on forKey:@"fav_notification"];
    } else if (sender == self.vibrationSwitch) {
        [prefs setBool:self.vibrationSwitch.on forKey:@"vibration"];
    } else if (sender == self.rangeSwitch) {
        [prefs setBool:self.rangeSwitch.on forKey:@"only_notify_in_range"];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == kCommonRangeCell || indexPath.row == kFavoriteRangeCell) {
        if(!self.pickerIndexPath || self.pickerIndexPath.row - 1 != indexPath.row) {
            switch (indexPath.row) {
                case kCommonRangeCell:
                    self.pickerIndexPath = [NSIndexPath indexPathForRow:kCommonRangePicker inSection:0];
                    break;
                case kFavoriteRangeCell:
                    self.pickerIndexPath = [NSIndexPath indexPathForRow:kFavoriteRangePicker inSection:0];
                    break;
            }
        } else {
            self.pickerIndexPath = nil;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kCommonRangeCell:
            if(!self.rangeSwitch.on) {
                return 0;
            }
            break;
        case kCommonRangePicker:
            if(indexPath == self.pickerIndexPath) {
                return self.pickerCellRowHeight;
            } else {
                return 0;
            }
            break;
        case kFavoriteRangeCell:
            if(!self.rangeSwitch.on) {
                return 0;
            }
            break;
        case kFavoriteRangePicker:
            if(indexPath == self.pickerIndexPath) {
                return self.pickerCellRowHeight;
            } else {
                return 0;
            }
            break;
    }
    
    return self.tableView.rowHeight;
}

#pragma mark - UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.rangePickerRanges.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    int value = [[self.rangePickerRanges objectAtIndex:row] intValue];
    
    if(value) {
        return [NSString stringWithFormat:@"%dm", value];
    } else {
        return @"∞m";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int rowInt = [[self.rangePickerRanges objectAtIndex:row] intValue];
    if(pickerView == self.commonRangePicker) {
        [prefs setInteger:rowInt forKey:@"common_notification_range"];
        self.commonRangeLabel.text = [NSString stringWithFormat:@"%dm", rowInt];
    } else if(pickerView == self.favoriteRangePicker) {
        [prefs setInteger:rowInt forKey:@"favorite_notification_range"];
        self.favoriteRangeLabel.text = [NSString stringWithFormat:@"%dm", rowInt];
    }
}

@end
