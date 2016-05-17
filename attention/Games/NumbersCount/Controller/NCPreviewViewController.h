//
//  NCPreviewViewController.h
//  attention
//
//  Created by Max on 06.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCGame.h"
#import "NCSettings.h"

@interface NCPreviewViewController : UIViewController

@property (strong, nonatomic) NCGame *game;
@property (nonatomic) NCSettings *settings;

@property (weak, nonatomic) IBOutlet UIButton *sequencePreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *beginGameButton;

@end
