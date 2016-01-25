//
//  ATQuestionViewController.m
//  attention
//
//  Created by Max on 20/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import "ATQuestionViewController.h"
#import "ATSuspectsResultViewController.h"
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


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void) viewDidAppear:(BOOL)animated {
    _scroll.alpha = 0.0;
    while (_scroll.subviews.count > 0) {
        [[_scroll.subviews lastObject] removeFromSuperview];
    }
    
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
    NSLog(@"Suspects: %@", [suspectSymbols componentsJoinedByString:@" "]);
    
    symbols = [[Utils getRandomizedSequence:symbols] mutableCopy];
    
    float width = _scroll.frame.size.width;
    float scrollHeight = _scroll.frame.size.height;
    
    int perRow = 3;
    float margin = 10.0;
    float swidth = (width - margin * 4.0) / 3.0;
    
    float y = scrollHeight / 2.0 - swidth;
    float x = margin;
    
    if (symbols.count / (float)perRow > 3) {
        y = margin;
    }
    
    for (NSInteger i = 0; i < symbols.count; i++) {

        if (i > 0 && 0 == i % perRow) {
            y = y + swidth + margin;
        }
        
        if (i > 0 && 0 == i % perRow) {
            x = margin;
            
            // if last row
            NSInteger left = symbols.count - i;

            if (left < perRow) {
                if (1 == left) {
                    x = width / 2.0 - swidth / 2.0;
                } else {
                    x = width / (float)left - swidth;
                }
            }

        }
        
        NSString *symbol = symbols[i];
        
        UIView *suspect = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + ((i % perRow) * 100), y, swidth, swidth)];;
        suspect.alpha = 0.5;

        [UIView animateWithDuration: 0.2
                              delay: i * 0.1
                            options:UIViewAnimationOptionCurveLinear
                         animations: ^{
                             suspect.frame = CGRectMake(x, suspect.frame.origin.y, swidth, swidth);
                         }
                         completion:^(BOOL finished){}];
        
//        suspect.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, swidth, swidth)];
//        l.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
        [suspect addSubview:l];
        
        l.text = [NSString stringWithFormat:@"%@", symbol];
        l.font = [UIFont systemFontOfSize:swidth - (swidth / 4.0)];
        l.textAlignment = NSTextAlignmentCenter;

        suspect.layer.cornerRadius = swidth / 5.0;
        suspect.layer.masksToBounds = YES;
        suspect.userInteractionEnabled = YES;
        
        UILabel *b = [[UILabel alloc] initWithFrame:CGRectMake(swidth - 26, swidth - 26, 24, 24)];
        b.text = @"";
        b.textColor = [UIColor grayColor];
        b.font = [UIFont systemFontOfSize:32];
        b.textAlignment = NSTextAlignmentCenter;

        b.userInteractionEnabled = YES;
        
        [suspect addSubview: b];
        
        
        [_scroll addSubview:suspect];
        
        [_scroll setContentSize:CGSizeMake(0, y + swidth)];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        suspect.tag = i + 100;
        [suspect addGestureRecognizer:tap];
        
        
        
        x = x + swidth + margin;
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

        v.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent: 0.6].CGColor;
        v.layer.borderWidth = 1.4;
        v.alpha = 1.0;
        v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.05];
//        ((UILabel*)v.subviews[1]).text = @"‼️";

    } else {
        [selectedSuspects removeObject:@(idx)];
        v.alpha = 0.5;
        v.layer.borderWidth = 0.0;
        v.backgroundColor = [UIColor clearColor];
//        ((UILabel*)v.subviews[1]).text = @"";
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
    
    for (int i = 0; i < selectedSuspects.count; i++) {
        NSInteger idx = [selectedSuspects[i] integerValue];
        NSString *symbol = symbols[idx];
        
        if (NSNotFound != [suspectSymbols indexOfObject:symbol]) {
            right++;
        } else {
            wrong++;
        }
    }
    
    BOOL win = NO;

    if (right == suspectSymbols.count && 0 == wrong) {
        win = YES;
    }
    
    NSString *title = @"You win!";
    NSString *message = @"You have found all of them!";
    
    if (!win) {
        title = @"Wrong!";
        message = [NSString stringWithFormat:@"Not all found. Right %li/%li, wrong %li", right, game.suspectCount ,wrong];
        [game decreaseDifficulty];
        
    } else {
        [game increaseDifficulty];
    }
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [UIView animateWithDuration:0.2 animations:^{
            _scroll.alpha = 0.0;
        }];
//        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:true completion:^{}];
        [self performSegueWithIdentifier:@"show_result" sender:self];
    
    }];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:true completion:^{}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id dest = [segue destinationViewController];
    
    if ([dest isKindOfClass:[ATSuspectsResultViewController class]]) {

        ((ATSuspectsResultViewController*)dest).mainController = _mainController;
    }

}


@end
