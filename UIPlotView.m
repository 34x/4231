///
//  UIPlotView.m
//  attention
//
//  Created by Max on 15/04/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "UIPlotView.h"

@implementation UIPlotView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)redraw {
    [self drawRect:self.frame];
}

- (void)drawRect:(CGRect)rect{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, 5.0);
//    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
//    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
//    CGColorRef color = CGColorCreate(colorspace, components);
//    CGContextSetStrokeColorWithColor(context, color);
//    CGContextMoveToPoint(context, 0, 0);
//    CGContextAddLineToPoint(context, 300, 400);
//    CGContextStrokePath(context);
//    CGColorSpaceRelease(colorspace);
//    CGColorRelease(color);
//
    
    if (!self.lineColor) {
        self.lineColor = [UIColor blueColor];
    }
    self.backgroundColor = [UIColor clearColor];

    if (!self.plotBackgroundColor) {
        self.plotBackgroundColor = [UIColor whiteColor];
    }
    
    CGRect frame = self.frame;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context) {
        CGContextSetFillColorWithColor(context, self.plotBackgroundColor.CGColor);
        
        CGContextFillRect(context, frame);
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);

        [self drawCurvedLine:context points:self.points];
        
        CGContextStrokePath(context);
    }
}

- (void) drawCurvedLine:(CGContextRef)context points:(NSArray*)points {
    
    if (0 == [points count]) {
        return;
    }
    

    
    float height = self.frame.size.height;
    float width = self.frame.size.width;
    
    __block float prevX = [points[0][0] floatValue];
    __block float prevY = [points[0][1] floatValue];
    __block float maximum = .0;
    __block float minimum = .0;
    __block float avarage = .0;
    
    NSArray *orderedPoints = [points sortedArrayUsingComparator:^(id obj1, id obj2) {
        
        NSInteger i1 = [[obj1 objectAtIndex:1] floatValue];
        NSInteger i2 = [[obj2 objectAtIndex:1] floatValue];
        
        if (i1 > i2) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (i1 < i2) {
            return (NSComparisonResult)NSOrderedAscending;
        }

        return (NSComparisonResult)NSOrderedSame;
    }];
    
    minimum = [orderedPoints[0][1] floatValue];
    maximum = [orderedPoints[[orderedPoints count] -1 ][1] floatValue];
    
    
    float multiple = (height - 20.) / maximum;
    float stepX = (width - 68.) / ((float)[points count] - 1);
    
    prevY = height - prevY;
    __block float x = 58.;
    
//    float rowHeight = (height - 10.) / ([points count]);

    __block float yLabelX = 0.;
    __block float yLabelWidth = 54.;
    __block float xLabelX = x - 28.;
    __block float xLabelY = height;
    
    int maxCols = 8;
    long divider = floor(([points count] / maxCols)) + 1;
    
    
    __block int iteration = 0;
    
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSArray *xy = (NSArray*)obj;
        NSNumber *xValue = [xy objectAtIndex:0];
        NSNumber *yValue = [xy objectAtIndex:1];

        float labelY;
        float y;
        /*
        y = [yValue floatValue] * multiple;
        // old way with same height
        // slow but true!
        y = ([orderedPoints indexOfObject:xy] + 1) * rowHeight;

        y = height - y;
        */
        
        float percent = ([yValue floatValue] + 1.0 - minimum) / ((maximum + 1.0 - minimum) / 100.0);
        
        y = (height - 30.) * (percent / 100.0);
        
        y = height - y - 10.;
        
        xLabelX = x - 25.;

        CGContextBeginPath(context);
        
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetLineWidth(context, .1);
        
        CGContextMoveToPoint(context, yLabelWidth + 4., y);
        CGContextAddLineToPoint(context, width, y);
        
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, height-4.);
        
        CGContextStrokePath(context);
        
        
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, 1.4);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        
        
        labelY = y - 10;
        
        if (0 == idx) {
            // first point!
            CGContextMoveToPoint(context, x, y);
        } else {
            CGContextMoveToPoint(context, prevX, prevY);
        }
        CGContextAddLineToPoint(context, x, y);
        CGContextStrokePath(context);
        
        
        
        CGContextBeginPath(context);
        
        CGContextAddArc(context, x, y, 3, 0, 360, 0);
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillPath(context);
        CGContextStrokePath(context);
        
        
        UIFont *labelFont = [UIFont fontWithName:@"Helvetica" size:9.];
        
//        NSUInteger yIndex = [orderedPoints indexOfObject:xy];
        
//        NSLog(@"%lu", yIndex);
//        if (floor(yIndex / divider) == (float)yIndex / (float)divider) {
        if ([yValue floatValue] == maximum || [yValue floatValue] == minimum) {
            UILabel *yLabel = [[UILabel alloc] initWithFrame:CGRectMake(yLabelX, labelY, yLabelWidth, 20.)];
            [yLabel setFont:labelFont];
            [yLabel setText:[NSString stringWithFormat:@"%.2f", [yValue floatValue]]];
            [yLabel setTextAlignment:NSTextAlignmentRight];
            
            [self addSubview:yLabel];
        }

        
        if (floor(iteration / divider) == (float)iteration / (float)divider) {
            
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelX, xLabelY, 50., 20.)];
            xLabel.text = [NSString stringWithFormat:@"%@", xValue];
            [xLabel setFont:labelFont];
            xLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:xLabel];
        }
        
        [UIView animateWithDuration:1.2
                         animations:^{
//                             view.frame = CGRectMake(rect.origin.x, rect.origin.y, paddingWidth + percentageWidth, rect.size.height);
        
//                             if ([[view subviews] count] > 0) {
//                                 UIView *l = [view subviews][0];
//                                 CGRect lrect = l.frame;
//                                 l.frame = CGRectMake(view.frame.size.width + 6., lrect.origin.y
//                                                      , lrect.size.width, lrect.size.height);
//                             }
                         }];

//        CGContextAddQuadCurveToPoint(context, x1, prevY, x, y);
//        CGContextAddCurveToPoint(context, y, y, 100., 100., x, y);
        
        prevX = x;
        prevY = y;
        x = x + stepX;
        iteration++;
    }];
}



@end
