//
//  ShapeView.m
//  HowManyC
//
//  Created by Max on 04/07/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "NCShapeView.h"

NSString *const NCShapeViewTypeBox = @"NCShapeViewTypeBox";
NSString *const NCShapeViewTypeTriangle = @"NCShapeViewTypeTriangle";
NSString *const NCShapeViewTypePyramid = @"NCShapeViewTypePyramid";
NSString *const NCShapeViewTypeCircle = @"NCShapeViewTypeCircle";
NSString *const NCShapeViewTypeOcto = @"NCShapeViewTypeOcto";

@interface NCShapeView()

@property CGMutablePathRef path;
@property CGMutablePathRef pathMargin;
@property (nonatomic, readwrite) NSString *type;

@property UIColor *shapeColor;

@end

@implementation NCShapeView
@synthesize path;
@synthesize pathMargin;
@synthesize type;
@synthesize drawShape;

- (instancetype) initWithFrame:(CGRect)frame andType:(NSString*)stype {
    self = [super initWithFrame:frame];

    if (self) {
        
        // to make clear color transparent!
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.fill = YES;
        self.alpha = 1.0;
        self.drawShape = YES;
        if (!stype) {
            type = NCShapeViewTypeCircle;
        } else {
            type = stype;
        }
        
        pathMargin = CGPathCreateMutable();
        
        CGPathAddArc(self.pathMargin, nil, frame.size.width / 2.0, frame.size.height / 2.0, frame.size.width / 2.0, 0.0, M_PI * 2.0, YES);
        
        CGPathCloseSubpath(pathMargin);
        
        
        path = CGPathCreateMutable();
        CGFloat centerX  = frame.size.width / 2.0;
        CGFloat centerY = frame.size.height / 2.0;
        
        
        CGFloat radius = frame.size.height / 2.0;
        
        CGFloat boxSideHalf = radius / sqrt(2.0);
        boxSideHalf = frame.size.width / 2.0;
        boxSideHalf = boxSideHalf * 0.9;
        
        
        CGFloat side = radius * sqrt(3.0);
//        CGFloat height = (sqrt(3.0) / 2.0) * side; // triangle height
        CGFloat sideHalf = side / 2.0;
        
        if (NCShapeViewTypeBox == type ) {
            CGFloat radius = frame.size.width * 0.1;
//            CGFloat radius2x = radius * 2.0;
            
            CGPathMoveToPoint(path, nil, centerX, centerY - boxSideHalf);
            
            CGPathAddArcToPoint(path, nil, centerX + boxSideHalf, centerY - boxSideHalf, centerX + boxSideHalf, centerY, radius);
            
            CGPathAddArcToPoint(path, nil, centerX + boxSideHalf, centerY + boxSideHalf, centerX, centerY + boxSideHalf, radius);
            
            CGPathAddArcToPoint(path, nil, centerX - boxSideHalf, centerY + boxSideHalf, centerX - boxSideHalf, centerY, radius);
            
            CGPathAddArcToPoint(path, nil, centerX - boxSideHalf, centerY - boxSideHalf, centerX, centerY - boxSideHalf, radius);
            
            

            
            //CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY - boxSideHalf);
//            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY + boxSideHalf);
//            CGPathAddLineToPoint(path, nil, centerX - boxSideHalf, centerY + boxSideHalf);
            
//            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY - boxSideHalf);
//            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY + boxSideHalf);
//            CGPathAddLineToPoint(path, nil, centerX - boxSideHalf, centerY + boxSideHalf);
            
        } else if (NCShapeViewTypeTriangle == type) {
            
//            CGPathMoveToPoint(path, nil, centerX, centerY - radius);
//            CGPathAddLineToPoint(path, nil, centerX + sideHalf, (centerY - radius) + height);
//            CGPathAddLineToPoint(path, nil, centerX - sideHalf, (centerY - radius) + height);
            
            CGPathMoveToPoint(path, nil, centerX, centerY - boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX + sideHalf, centerY + boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX - sideHalf, centerY + boxSideHalf);
            
        } else if (NCShapeViewTypePyramid == type) {
            CGPathMoveToPoint(path, nil, centerX - boxSideHalf / 2.0, centerY - boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf / 2.0, centerY - boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX + sideHalf, centerY + boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX - sideHalf, centerY + boxSideHalf);
        }else if (NCShapeViewTypeOcto == type) {
            CGPathMoveToPoint(path, nil, centerX - boxSideHalf / 2.0, centerY - boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf / 2.0, centerY - boxSideHalf);
            
            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY - boxSideHalf / 2.0);
            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf, centerY + boxSideHalf / 2.0);
            CGPathAddLineToPoint(path, nil, centerX + boxSideHalf / 2.0, centerY + boxSideHalf);
            
            CGPathAddLineToPoint(path, nil, centerX - boxSideHalf / 2.0, centerY + boxSideHalf);
            CGPathAddLineToPoint(path, nil, centerX - boxSideHalf, centerY + boxSideHalf / 2.0);
            CGPathAddLineToPoint(path, nil, centerX - boxSideHalf, centerY - boxSideHalf / 2.0);
            

        } else {
            
            CGPathAddArc(path, nil, frame.size.width / 2.0, frame.size.height / 2.0, boxSideHalf, 0.0, M_PI * 2.0, YES);
//            CGPathAddArc(path, nil, frame2.size.width / 2.0 + frame.size.width / 2.0 - frame.size.width / 4.0, frame2.size.height / 2.0, frame.size.width / 10.0, 0.0, M_PI * 2.0, NO);
        }
        
        CGPathCloseSubpath(path);
    }
    
    
    //    CABasicAnimation *rot = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    rot.fromValue = @(M_PI * 2.0);
    //    rot.toValue =  @(M_PI);
    //    rot.repeatCount = 100;
    //    rot.duration = 4.0;
    //
    //    [self.layer addAnimation:rot forKey:@"rot"];
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!drawShape) {
        return;
    }
    UIColor *color = self.shapeColor;
//    self.backgroundColor = [UIColor clearColor];
    
//    color = self.backgroundColor;
    
    CGContextRef context  = UIGraphicsGetCurrentContext();
    
//    CGContextBeginPath(context);
//    CGContextClearRect(context, self.frame);
//    CGContextClearRect(context, self.bounds);
    
    
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextFillRect(context, self.bounds);
    
    
    //        CGContextAddPath(context, pathMargin)
    //        CGContextFillPath(context)
    
    //        var tr = CGPathCreateMutable()
    //        CGPathAddArc(tr, nil, frame.width / 2.0, frame.height / 2.0, frame.width / 4.0, 0.0, CGFloat(M_PI) * 2.0, true)
    //        CGPathCloseSubpath(tr)
    //        CGContextAddPath(context, tr)
    //        CGContextFillPath(context)
    
    
    CGContextBeginPath(context);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddPath(context, path);
    if (self.fill) {
        CGContextFillPath(context);
    } else {
        CGContextSetLineWidth(context, self.frame.size.width * 0.02);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
    }
    
    
    
    
    CGContextSaveGState(context);
    
    self.layer.shouldRasterize = true;
    self.layer.rasterizationScale =  [UIScreen mainScreen].scale;
    
    [self addShadow];
}

-(void)setFill:(BOOL)fill {
    _fill = fill;
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.shapeColor = backgroundColor;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (CGPathContainsPoint(pathMargin, nil, point, true)) {
//        return self;
//    } else {
//        return nil;
//    }
//}

- (void) addShadow {
    // add shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    if (self.frame.size.width > 16) {
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 0.6;
    } else {
        self.layer.shadowOffset = CGSizeMake(0, 0.2);
        self.layer.shadowOpacity = 0.4;
    }
    
    self.layer.shadowRadius = 1;
    
    
    //    self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:b] CGPath];
}


@end
