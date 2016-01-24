//
//  AttentionShape.h
//  attention
//
//  Created by Max on 18/09/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ATShape : NSObject
@property NSInteger size;
@property CGPoint position;
@property UIView *view;
@property NSString *text;
@property BOOL isRight;
@property BOOL isSelected;

- (instancetype) initWithPosition:(CGPoint)inPosition size:(NSInteger)initSize;
@end
