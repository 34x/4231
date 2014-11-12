//
//  ViewController.h
//  attention
//
//  Created by Max on 20/09/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCGame.h"
@interface NCGameViewController : UIViewController
@property (strong, nonatomic) NCGame *game;
- (void) restartGame;
@end

