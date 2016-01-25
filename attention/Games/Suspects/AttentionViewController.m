//
//  AttentionViewController.m
//  attention
//
//  Created by Max on 18/09/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "AttentionViewController.h"
#import "ATQuestionViewController.h"
#import "ATShape.h"
#import "NCGame.h"
#import "ATGame.h"



@interface AttentionViewController () <ATGameDelegate>
@property (nonatomic) UIView *boardView;

@property float cellPointsSize;

@property (nonatomic) NSInteger test;
@property (strong, nonatomic) ATGame *game;
@end

@implementation AttentionViewController
@synthesize boardView;
@synthesize cellPointsSize;
@synthesize game;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = self.view.bounds;
    float topMargin = 64.0;
    boardView = [[UIView alloc] initWithFrame:CGRectMake(0, topMargin, frame.size.width, frame.size.height - topMargin)];
//    boardView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:boardView];
    
//    boardView.layer.borderColor = [UIColor greenColor].CGColor;
//    boardView.layer.borderWidth = 1.0;
    
    
    NSInteger cols = 32;
    cellPointsSize = boardView.frame.size.width / cols;
    NSInteger rows = boardView.frame.size.height / cellPointsSize;
    
    game = [[ATGame alloc] initWithCols:cols rows:rows];
    
    NSLog(@"board size: %li %li %f", cols, rows, cellPointsSize);

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.view addGestureRecognizer:tap];
}

- (void) tapOnView {
    [game finish];
}

- (void) atGameFinish:(ATGame *)game {
    NSLog(@"finish");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSMutableArray *hidingItems = [NSMutableArray new];
        
        NSLog(@"total: %li", [boardView.subviews count]);
        

        for (int i = 0; i < boardView.subviews.count; i++) {

            UIView *v = boardView.subviews[i];
            
            if (NSNotFound != [hidingItems indexOfObject:v]) {
                continue;
            }
            [hidingItems addObject:v];
            
            
            [UIView animateWithDuration:1.2 animations:^{
                v.alpha = 0.0;
                
            } completion:^(BOOL finished){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [v removeFromSuperview];
                    if (0 == boardView.subviews.count) {
                        [self performSegueWithIdentifier:@"show_question" sender:nil];
                    }

                }];
                
            }];
        }
    }];
    

}

- (void) viewDidAppear:(BOOL)animated {
    game.delegate = self;
    
    [game start];
}



- (void) addShape:(ATShape*)shape {

    UIView *shapeView = [[UIView alloc] initWithFrame:CGRectMake(cellPointsSize * shape.position.x, cellPointsSize * shape.position.y, cellPointsSize * shape.size, cellPointsSize * shape.size)];
    
    shape.view = shapeView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellPointsSize * shape.size, cellPointsSize * shape.size)];
    
    label.font = [UIFont systemFontOfSize:shape.size * cellPointsSize];
    label.textAlignment = NSTextAlignmentCenter;
    
    
    shapeView.alpha = 0.0;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        label.text = shape.text;
        [shape.view addSubview:label];
        [boardView addSubview:shapeView];
        
        
        [UIView animateWithDuration:1.2 animations:^{
            shapeView.alpha = 1.0;
        }];

    }];

}

- (void) removeShape:(ATShape*)shape {

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:1.8 animations:^{
            shape.view.alpha = 0.0;
            
        } completion:^(BOOL finished){
            
            [shape.view removeFromSuperview];
            [game shapeDidRemove:shape];
        }];
        
    }];
    
    
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
    
    if ([dest isKindOfClass:[ATQuestionViewController class]]) {
        ((ATQuestionViewController*)dest).game = game;
    }
}


@end
