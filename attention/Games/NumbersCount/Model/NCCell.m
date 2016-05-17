//
//  Cell.m
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCCell.h"

@implementation NCCell
- (NSString*) description {
    return [NSString stringWithFormat:@"<NCCell: %@ (%lu)>", self.text, (unsigned long)self.value];
}
@end
