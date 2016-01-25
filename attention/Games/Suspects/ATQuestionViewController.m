//
//  ATQuestionViewController.m
//  attention
//
//  Created by Max on 20/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import "ATQuestionViewController.h"
#import "ATShape.h"
#import "Utils.h"

@interface ATQuestionViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property NSArray *shapes;
@property NSMutableArray *suspectSymbols;
@property NSMutableArray *selectedSuspects;
@property NSMutableArray *symbols;
@end

@implementation ATQuestionViewController
@synthesize game;
@synthesize shapes;
@synthesize suspectSymbols;
@synthesize selectedSuspects;
@synthesize symbols;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    _scroll.alpha = 0.0;
    
    shapes = [game getShapes];
    
    selectedSuspects = [[NSMutableArray alloc] init];
    symbols = [[NSMutableArray alloc] init];
    suspectSymbols = [[NSMutableArray alloc] init];
    NSMutableArray *otherSymbols = [[NSMutableArray alloc] init];
    NSArray *allSymbols = [Utils getRandomizedSequence:[game getSymbols]];
    
    for (int i = 0; i < [shapes count]; i++) {
        ATShape *shape = shapes[i];
        
        if (shape.isRight) {
            [suspectSymbols addObject:shape.text];
        } else {
            [otherSymbols addObject:shape.text];
        }
    }
    
    
    [symbols addObjectsFromArray:suspectSymbols];
    for (int i = 0; i < [allSymbols count]; i++) {
        NSString *symbol = allSymbols[i];
        if (NSNotFound == [otherSymbols indexOfObject:symbol] && NSNotFound == [symbols indexOfObject:symbol]) {
            [symbols addObject:symbol];
            if ([symbols count] >= [shapes count]) {
                break;
            }
        }
    }
    
    symbols = [[Utils getRandomizedSequence:symbols] mutableCopy];
    
    float width = _scroll.bounds.size.width;
    
    
    for (int i = 0; i < [self.scroll.subviews count]; i++) {
        [self.scroll.subviews[i] removeFromSuperview];
    }
    
    float swidth = width - (width / 5.0);
    for (int i = 0; i < [symbols count]; i++) {
        //        ATShape *shape = shapes[i];
        NSString *symbol = symbols[i];
        
        UIView *suspect = [[UIView alloc] initWithFrame:CGRectMake((i * width), 50, width, width)];;
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, swidth)];
//        l.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.05];
        [suspect addSubview:l];
        
        l.text = [NSString stringWithFormat:@"%@", symbol];
        l.font = [UIFont systemFontOfSize:swidth];
        l.textAlignment = NSTextAlignmentCenter;

//        suspect.layer.cornerRadius = (width - 40.0) / 2.0;
//        suspect.layer.masksToBounds = true;
        suspect.userInteractionEnabled = true;
        
        UILabel *b = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, suspect.frame.size.width, 24)];
        b.text = @"";
        b.textColor = [UIColor grayColor];
        b.font = [UIFont systemFontOfSize:24];
        b.textAlignment = NSTextAlignmentCenter;

        b.userInteractionEnabled = true;
        
        [suspect addSubview: b];
        
        
        [self.scroll addSubview:suspect];
        
        [self.scroll setContentSize:CGSizeMake((i + 1) * width, 0)];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        suspect.tag = i + 100;
        [suspect addGestureRecognizer:tap];
    }
    
    [UIView animateWithDuration:0.1 animations:^(){
        _scroll.alpha = 1.0;
    }];
}

- (void) tap:(UIGestureRecognizer*)sender {
    NSInteger idx = sender.view.tag - 100;
    UIView *v = [self.scroll viewWithTag:sender.view.tag];

    if (NSNotFound == [selectedSuspects indexOfObject:@(idx)]) {
        [selectedSuspects addObject:@(idx)];

//        v.layer.borderColor = [[UIColor redColor].CGColor];
//        v.layer.borderWidth = 4.0;
        
        ((UILabel*)v.subviews[1]).text = @"‼️";

    } else {
        [selectedSuspects removeObject:@(idx)];
        
//        v.layer.borderWidth = 0.0;
        ((UILabel*)v.subviews[1]).text = @"";
    }
    
    NSLog(@"%@", selectedSuspects);
}

- (IBAction)checkAnswer:(id)sender {
    
    if (0 == [selectedSuspects count]) {
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No one selected" message:@"pick someone as suspect!" preferredStyle:UIAlertControllerStyleAlert];
        
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            
        }];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:true completion:^{}];
        
        return;
    }
    
    
    
    
    NSInteger right = 0;
    NSInteger wrong = 0;
    
    for (int i = 0; i < [selectedSuspects count]; i++) {
        NSInteger idx = [selectedSuspects[i] integerValue];
        NSString *symbol = symbols[idx];
        
        if (NSNotFound != [suspectSymbols indexOfObject:symbol]) {
            right++;
        } else {
            wrong++;
        }
    }
    
    BOOL win = false;

    if (right == [suspectSymbols count] && 0 == wrong) {
        win = true;
    }
    
    NSString *title = @"You win!";
    NSString *message = @"You have found all of them!";
    
    if (!win) {
        title = @"Wrong!";
        message = [NSString stringWithFormat:@"Not all found. Right %li/%li, wrong %li", right, game.suspectCount ,wrong];
        if (game.totalCount > 2) {
            if (game.totalCount > game.suspectCount) {
                game.totalCount--;
            } else {
                game.suspectCount--;
            }
        }
    } else {
        game.totalCount++;
        
        if (game.totalCount > 6) {
            game.suspectCount++;
            game.totalCount = game.suspectCount + 1;
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [UIView animateWithDuration:0.2 animations:^{
            _scroll.alpha = 0.0;
        }];
        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:true completion:^{}];
    
    }];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:true completion:^{}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
