//
//  ATSuspectsResultViewController.h
//  attention
//
//  Created by Max on 25.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSuspectsMainViewController.h"

@interface ATSuspectsResultViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic) ATSuspectsMainViewController *mainController;
@end
