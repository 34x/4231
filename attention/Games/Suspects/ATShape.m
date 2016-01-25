//
//  AttentionShape.m
//  attention
//
//  Created by Max on 18/09/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "ATShape.h"

@interface ATShape()

@end

@implementation ATShape
@synthesize position;
@synthesize size;

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.isRight = false;
        self.isSelected = false;;
    }
    
    return self;
}

- (instancetype) initWithPosition:(CGPoint)inPosition size:(NSInteger)initSize {
    self = [self init];
    
    if (self) {
        self.position = inPosition;
        size = initSize;
    }
    
    return self;
}

@end
