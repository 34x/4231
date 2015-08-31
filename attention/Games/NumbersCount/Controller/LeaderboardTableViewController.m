//
//  LeaderboardTableViewController.m
//  attention
//
//  Created by Max on 20/07/15.
//  Copyright (c) 2015 Max. All rights reserved.
//
#import "GCHelper.h"
#import <GameKit/GameKit.h>
#import "LeaderboardTableViewController.h"
#import "PiwikTracker.h"

@interface LeaderboardTableViewController ()
@property (nonatomic) NSArray *scores;
@property (nonatomic) UIView *spinnerView;
@end

@implementation LeaderboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[GCHelper sharedInstance] getLeaderboardWithCompletionHandler:^(NSArray *scores){
        self.scores = scores;
        [self.tableView reloadData];
        [UIView animateWithDuration:0.2 animations:^{
            self.spinnerView.alpha = 0.0;
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendView:@"leaderboard"];
    
    if (!self.spinnerView) {
        self.spinnerView = [[UIView alloc] initWithFrame:self.view.frame];
        self.spinnerView.backgroundColor = [UIColor grayColor];
        self.spinnerView.userInteractionEnabled = false;
        [self.view addSubview:self.spinnerView];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        spinner.center = CGPointMake(self.spinnerView.frame.size.width / 2.0, self.spinnerView.frame.size.height / 2.0);
        
        [self.spinnerView addSubview:spinner];
        
        [spinner startAnimating];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (nil == self.scores) {
        return 0;
    } else {
        return [self.scores count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    GKScore *score = (GKScore*)[self.scores objectAtIndex:indexPath.row];
    
    
    ((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"#%li", score.rank];
    ((UILabel*)[cell viewWithTag:2]).text = score.player.alias;
    ((UILabel*)[cell viewWithTag:3]).text = [NSString stringWithFormat:@"%.2f", (float)score.value / 100];;
    
    
    return cell;
}






@end
