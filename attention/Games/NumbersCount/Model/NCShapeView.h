//
//  NCShape.h
//  attention
//
//  Created by Max on 20.04.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const NCShapeViewTypeBox;
FOUNDATION_EXPORT NSString *const NCShapeViewTypeTriangle;
FOUNDATION_EXPORT NSString *const NCShapeViewTypePyramid;
FOUNDATION_EXPORT NSString *const NCShapeViewTypeCircle;
FOUNDATION_EXPORT NSString *const NCShapeViewTypeOcto;


@interface NCShapeView : UIView
@property (nonatomic, readonly) NSString *type;
@property (nonatomic) BOOL fill;
@property (nonatomic) BOOL drawShape;
- (instancetype) initWithFrame:(CGRect)frame andType:(NSString*)stype;
@end
