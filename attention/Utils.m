//
//  Utils.m
//  attention
//
//  Created by Max on 20/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+ (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        id cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}
@end
