//
//  Feedback.m
//  attention
//
//  Created by Max on 05.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "FeedbackViewController.h"
#import "ATSettings.h"

@interface FeedbackViewController()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *portraitView;
@property (weak, nonatomic) IBOutlet UIView *landscapeView;


@property (nonatomic) UITextView *infoMessage;
@end

@implementation FeedbackViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    _textView.text = @"";
    
    _infoMessage = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 192.0, 64.0)];
    _infoMessage.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _infoMessage.textAlignment = NSTextAlignmentCenter;
    _infoMessage.layer.cornerRadius = 8;
    _infoMessage.layer.masksToBounds = YES;
    _infoMessage.textColor = [UIColor whiteColor];
    _infoMessage.text = @"Thank you!";
    _infoMessage.font = [UIFont systemFontOfSize:18.0];
    _infoMessage.hidden = YES;
    
    [self.view addSubview:_infoMessage];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _infoMessage.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 4.0);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateOrientation];
    
    
    NSString *draft = [[ATSettings sharedInstance] get:@"feedback_draft"];
    if (draft) {
        _textView.text = draft;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}


-(void) orientationDidChange:(NSNotification*) notification {
    [self updateOrientation];
}

- (void) updateOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        self.landscapeView.hidden = NO;
        self.portraitView.hidden = YES;
    }
    else
    {
        self.landscapeView.hidden = YES;
        self.portraitView.hidden = NO;
    }

}

- (IBAction)sendAction:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.enabled = NO;
    
    NSURL *url = [NSURL URLWithString: [[ATSettings sharedInstance] get:@"feedback_url"]];
    url = [NSURL URLWithString:@"foobar"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    req.HTTPMethod = @"POST";
    [req addValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
    [req addValue:@"XMLHttpRequest" forHTTPHeaderField: @"X-Requested-With"];
    
    NSString *text = [self.textView.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet new]];
    NSString *body = [NSString stringWithFormat:@"type=feedback&description=[attention]%@&referer=attention", text];
    req.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSOperationQueue *urlQueue = [NSOperationQueue new];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:urlQueue];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLSessionTask *task = [session dataTaskWithRequest:req
                                        completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                            
                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                            
                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                CGPoint center = _infoMessage.center;
                                                if (error) {
                                                    _infoMessage.text = @"Error happen,\nplease try again later\nor send feedback from the website.";
                                                    _infoMessage.frame = CGRectMake(0, 0, 312, 92);
                                                
                                                    [[ATSettings sharedInstance] setSettingValue:_textView.text forKey:@"feedback_draft"];
                                                } else {
                                                    [[ATSettings sharedInstance] setSettingValue:@"" forKey:@"feedback_draft"];
                                                    _infoMessage.frame = CGRectMake(0, 0, 192, 64);
                                                    _infoMessage.text = @"✓\nThank you!";
                                                }

                                                _infoMessage.center = center;
                                            
                                                [self showInfoMessage:^{
                                                    button.enabled = YES;
                                                    [self cancelAction:nil];
                                                }];
                                            }];
                                        }];
    
    [task resume];

}

- (void) showInfoMessage:(void(^)()) completionHandler {
    _infoMessage.alpha = 0.0;
    _infoMessage.hidden = NO;
    [UIView animateKeyframesWithDuration:0.4
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  _infoMessage.alpha = 1.0;
                                  
                              } completion:^(BOOL finished){
                                  [UIView animateKeyframesWithDuration:0.6
                                                                 delay:3.0
                                                               options:UIViewKeyframeAnimationOptionAllowUserInteraction
                                                            animations:^{
                                                                _infoMessage.alpha = 0.0;
                                                                
                                                            }
                                                            completion:^(BOOL finished){
                                                                _infoMessage.hidden = YES;
                                                                completionHandler();
                                                            }];
                                  
                              }];
}


- (IBAction)cancelAction:(id)sender {
    [_textView resignFirstResponder];
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:0.2];
}

- (void) dismissView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
