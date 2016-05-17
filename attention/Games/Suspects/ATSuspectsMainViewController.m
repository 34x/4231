//
//  AttentionViewController.m
//  attention
//
//  Created by Max on 18/09/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "ATSuspectsMainViewController.h"
#import "ATQuestionViewController.h"
#import "ATShape.h"
#import "NCGame.h"
#import "ATGame.h"
#import "PiwikTracker.h"



@interface ATSuspectsMainViewController () <ATGameDelegate>
@property (nonatomic) UIView *boardView;

@property float cellPointsSize;

@property (nonatomic) NSInteger test;
@property (strong, nonatomic) ATGame *game;
@end

@implementation ATSuspectsMainViewController
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

//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
//    [self.view addGestureRecognizer:tap];
}

- (void) tapOnView {
    [game finish];
}

- (void) atGameFinish:(ATGame *)game {
    NSLog(@"finish");

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self performSegueWithIdentifier:@"show_question" sender:nil];
    }];
    

}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    
    [[PiwikTracker sharedInstance] sendViews: @"suspects", @"main", nil];
    
    game.delegate = self;
    
    [game start];
}



- (void) addShape:(ATShape*)shape {

    float shapeSize = cellPointsSize * shape.size;
    float fontSize = shapeSize - (shapeSize / 10.0);
    float x = cellPointsSize * shape.position.x;
    float y = cellPointsSize * shape.position.y;
    
    
    

    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIView *shapeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, shapeSize, shapeSize)];
        
        shape.view = shapeView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shapeSize, shapeSize)];
        
        label.font = [UIFont systemFontOfSize:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        
        shapeView.alpha = 0.0;
        
        label.text = shape.text;
        [shape.view addSubview:label];

        [boardView addSubview:shapeView];
        
        
        [UIView animateWithDuration:1.2 animations:^{
            shapeView.alpha = 1.0;
        } completion: ^(BOOL finished) {
            [game shapeDidAdd:shape];
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
        ((ATQuestionViewController*)dest).mainController = self;
    }
}


@end
