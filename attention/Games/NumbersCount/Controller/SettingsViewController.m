//
//  NumbersCountSettingsViewController.m
//  attention
//
//  Created by Max on 26/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "SettingsViewController.h"
#import "NCSettings.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *colsPicker;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic) NSArray *numbers;
@property (nonatomic) NCSettings *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.numbers = @[
        @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11"
    ];
    
    self.colsPicker.delegate = self;
    
    self.colsPicker.tag = 0;
    
    [self.colsPicker reloadAllComponents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.settings = [[NCSettings alloc] init];
    
    NSInteger colsIndex = [self.numbers indexOfObject:[NSString stringWithFormat:@"%d", self.settings.cols]];
    
    if (colsIndex > [self.numbers count]) {
        colsIndex = 0;
    }
    
    [self.sizeLabel setText:[NSString stringWithFormat:@"Grid size: %@ x %d", [self.numbers objectAtIndex:colsIndex], self.settings.rows]];
    
    [self.colsPicker selectRow:colsIndex inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [self.numbers count];
}
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}



- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [self.numbers objectAtIndex:row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if (0 == pickerView.tag) {
//        self.settings.cols = [[self.numbers objectAtIndex:row] intValue];
//    } else {
//        self.settings.rows = [[self.numbers objectAtIndex:row] intValue];
//    }
    
    int cols = [[self.numbers objectAtIndex:row] intValue];
    int rows;
    if (6 == cols) {
        rows = 7;
    } else {
        rows = cols + 2;
    }
    [self.sizeLabel setText:[NSString stringWithFormat:@"Grid size: %d x %d", cols, rows]];
    
    self.settings.rows = rows;
    self.settings.cols = cols;
    
    [self.settings save];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
