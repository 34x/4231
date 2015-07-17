//
//  UIPlotView.h
//  attention
//
//  Created by Max on 15/04/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlotView : UIView
@property(nonatomic, readwrite) UIColor *lineColor;
@property(nonatomic, readwrite) UIColor *plotBackgroundColor;
@property(nonatomic, readwrite) NSArray *points;

//- (instancetype)initWithPoints:(NSArray*)points;
- (void)redraw;
@end
