//
//  ATQuestionViewController.h
//  attention
//
//  Created by Max on 20/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATGame.h"
#import "ATSuspectsMainViewController.h"

@interface ATQuestionViewController : UIViewController
@property (nonatomic) ATGame *game;
@property (nonatomic) ATSuspectsMainViewController *mainController;
@end
