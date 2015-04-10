//
//  Cell.h
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NCCell : NSObject
@property (nonatomic) NSUInteger value;
@property (nonatomic) NSString *text;
@property (nonatomic) NSUInteger fontSize;
@property (nonatomic) UIColor* color;
@end
