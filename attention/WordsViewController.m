//
//  WordsViewController.m
//  attention
//
//  Created by Max on 31/08/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "WordsViewController.h"

@interface WordsViewController()
@property (weak, nonatomic) IBOutlet UITextView *sentenceTextView;
@property (weak, nonatomic) IBOutlet UITableView *answersTable;

@end

@implementation WordsViewController

- (void)viewDidLoad {
    self.answersTable.delegate = self;
    self.answersTable.dataSource = self;
}
- (void) viewDidAppear:(BOOL)animated {
    
    [self updateSentence];
}

- (IBAction)topRightButtonClicked:(id)sender {
    [self updateSentence];
}

- (void) updateSentence {
    NSString *text = @"The apple was ~colour~ and ~size~.";
    NSArray *colours = @[@"green", @"yellow", @"red"];
    NSArray *sizes = @[@"big", @"small", @"medium"];
    
    NSString *colour = colours[arc4random() %[colours count]];
    NSString *size = sizes[arc4random() %[sizes count]];
    text = [text stringByReplacingOccurrencesOfString:@"~colour~" withString:colour];
    text = [text stringByReplacingOccurrencesOfString:@"~size~" withString:size];
    
    self.sentenceTextView.text = text;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return @"Which colour?";
    } else {
        return @"Which size?";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%li-%li", indexPath.section, indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
}

@end
