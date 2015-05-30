//
//  NumbersCountSettings.h
//  attention
//
//  Created by Max on 29/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCSettings : NSObject
@property (nonatomic) int cols;
@property (nonatomic) int rows;
@property (nonatomic) int sequence;
@property (nonatomic) NSMutableDictionary *sequencesSettings;

-(id)init;
-(void)save;
-(NSMutableDictionary*)getSequenceSettings:(NSString*)sid;
+(NSArray*)getBoardSizes;
@end
