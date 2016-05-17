//
//  ATSuspectsResultViewController.m
//  attention
//
//  Created by Max on 25.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "ATSuspectsResultViewController.h"
#import "PiwikTracker.h"

@interface ATSuspectsResultViewController ()

@end

@implementation ATSuspectsResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [[PiwikTracker sharedInstance] sendViews: @"suspects", @"result", nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onButtonClick:(id)sender {
    [self.navigationController popToViewController:_mainController animated:YES];
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
