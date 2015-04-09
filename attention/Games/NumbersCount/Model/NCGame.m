//
//  Game.m
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCGame.h"
#import "NCCell.h"
@interface NCGame()
@property (readwrite, nonatomic) NSUInteger total;
@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic, readwrite) NSUInteger currentNumber;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, readwrite) NSUInteger duration;
@property (nonatomic, readwrite) NSUInteger colorsCount;
@property (nonatomic, readwrite) NSUInteger fontsCount;
@property (nonatomic, readwrite) BOOL isDone;
@property (nonatomic, readwrite) BOOL isComplete;
@property (nonatomic, readwrite) BOOL isStarted;
@property (nonatomic, readwrite) NSUInteger clicked;
@property (nonatomic, readwrite) NSMutableArray *randomizedSequence;
@end

@implementation NCGame

- (instancetype) initWithTotal:(NSUInteger)total
{
    self = [super init];
    
    if (self) {
        self.total = total;
        self.timeLimit = 30;
        self.difficultyLevel = 0;
        self.sequenceLevel = 0;
        self.clicked = 0;
        
        self.isStarted = NO;
        self.isDone = NO;
        self.isComplete = NO;
    }

    return self;
}

- (NSMutableArray*)items
{
    if (!_items) _items = [[NSMutableArray alloc] init];
    return _items;
}

- (BOOL)select:(NSUInteger)index value:(NSString*)value
{
    NCCell *cell = self.items[index];

    if (self.currentNumber == index || [cell.text isEqualToString:value]) {
        self.currentNumber++;
        self.currentIndex++;
        self.clicked++;
        
        if (self.currentIndex >= [self.items count]) {
            self.isComplete = YES;
            [self finish];
        }

        return YES;
    } else {
        return NO;
    }
}

- (void)timerTick
{
    self.duration++;
    if (self.duration >= self.timeLimit) {
        [self finish];
    }
}

+ (NSArray*)getSymbols:(NSString*)key {
    //    @[@"А", @"Б", @"В", @"Г", @"Д", @"Е", @"Ж", @"З", @"И", @"К", @"Л", @"М", @"Н", @"О", @"П", @"Р", @"С", @"Т", @"У", @"Ф", @"Х", @"Ц", @"Ч", @"Ш", @"Щ", @"Ъ", @"Ы", @"Ь", @"Э", @"Ю", @"Я"];
    
    NSMutableArray *numbersFrom1 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < 100; i++) {
        [numbersFrom1 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    NSDictionary *symbols = @{
                              @"numbersFrom1" : numbersFrom1,
                              @"numbers" : @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"],
                              @"numbersLetters" : @[
                                                    @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                                                    @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    ],
                              
                              @"letters" : @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                                             @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
                                             @"X", @"Y", @"Z"],
                              @"emoji" : @[@"🌳", @"🎄", @"🎼", @"🎭", @"🏁", @"🍄", @"🍀", @"🌍", @"🌚", @"🍍", @"🍒", @"🍴", @"🎃", @"🚲", @"🚧", @"🚀", @"📖", @"👣", @"👻", @"👽", @"🌴", @"🐲", @"🐬", @"☔️", @"🎸", @"⚽️", @"😱", @"🌻", @"⛅️", @"❄️", @"🍉", @"🎁", @"🎯", @"🚜", @"🏠", @"📱", @"⌚️", @"🎥", @"💾", @"💿", @"📡", @"💰", @"🔑"],
                              @"katakana" : @[@"ア",@"イ",@"ウ",@"エ",@"オ",@"カ",@"キ",@"ク",@"ケ",@"コ",@"サ",@"シ",@"ス",@"セ",@"ソ"]
                              };

    return symbols[key];
}

+ (NSArray*)getSequencesParams {

    NSArray *sequencesSettings = @[
                     @{
                         @"symbols" : @"numbersFrom1",
                         @"label" : @"Numbers"
                         },
                     @{
                         @"symbols" : @"letters",
                         @"label" : @"Letters"
                         },
                     @{
                         @"symbols" : @"emoji",
                         @"label" : @"Random Emoji",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"symbols" : @"numbers",
                         @"label"   : @"Random numbers",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"symbols" : @"numbersLetters",
                         @"label"   : @"Random numbers & letters",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"symbols" : @"katakana",
                         @"label" : @"Katakana (don't be scared)"
                         },
                     @{
                         @"symbols" : @"katakana",
                         @"label"   : @"Random Katakana %)",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     ];
    
    return sequencesSettings;
}

- (NSMutableArray*)getSequence:(NSUInteger)sequenceLevel difficultyLevel:(NSUInteger)difficultyLevel {
    NSMutableArray *sequence;

    NSArray *sequencesSettings = [NCGame getSequencesParams];
    
    if (sequenceLevel > [sequencesSettings count]) {
        sequenceLevel = 0;
    }
    
    NSDictionary *settings = [sequencesSettings objectAtIndex:sequenceLevel];
    NSArray *symbols = [NCGame getSymbols:[settings objectForKey:@"symbols"]];
    
    if (nil == [settings objectForKey:@"generator"]) {
        sequence = [NCGame createLimitSequence:self.total symbols:symbols];
    } else {
        SEL selector = NSSelectorFromString([settings objectForKey:@"generator"]);
        sequence = [self performSelector:selector withObject:symbols];
        sequence = [NCGame createLimitSequence:self.total symbols:sequence];
    }
    
    return sequence;
}

+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols {
    NSMutableArray *sequence = [[NSMutableArray alloc] init];
    
    NSString *val;
    NSUInteger symbolsCount = [symbols count];

    for (NSUInteger i = 0; i < total; i++) {

        if (i < symbolsCount) {
            val = [NSString stringWithFormat:@"%@", [symbols objectAtIndex:i]];
        } else if (i < symbolsCount * 2){
            val = [NSString stringWithFormat:@"%@%@",
                   [symbols objectAtIndex:0],
                   [symbols objectAtIndex:i - symbolsCount]
                   ];
        } else {
            break;
        }

        [sequence addObject:[NSString stringWithFormat:@"%@", val]];
    }

    return sequence;
}

- (void)generateItems:(BOOL)reverse {
    [self.sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NCCell *cell = [[NCCell alloc] init];
        
        cell.value = idx;
        cell.text = obj;
        [self.items addObject:cell];
    }];
}

+ (NSMutableArray*)randomizeArray:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = itemsOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}


+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = itemsOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getItems {

    // filling up
    self.sequence = [self getSequence:self.sequenceLevel difficultyLevel:self.difficultyLevel];

    [self generateItems:NO];
    
    //randomizing
    self.items = [NCGame randomize:self.items];
    
    return self.items;
}

- (void) start
{
    self.isStarted = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}
- (void) finish
{
    if (self.isDone) {
        return;
    }
    self.isDone = YES;
    
    if(self.timer) {
        [self.timer invalidate];
    }
    
    if (self.isComplete) {
        NSLog(@"GAME IS DONE!");

        NSDate *date = [NSDate date];
        
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        // seems like a hack
        id obj = [def objectForKey:@"log"];
        NSMutableArray *log;
        if (nil == obj) {
            log = [[NSMutableArray alloc] init];
        } else {
            log = [obj mutableCopy];
        }
        
        [log addObject:@[date,
                         [NSNumber numberWithUnsignedInteger:self.total],
                         [NSNumber numberWithUnsignedInteger:self.duration],
                ]
         ];
        
        [def setObject:log forKey:@"log"];
        [def synchronize];

    } else {
        NSLog(@"game not done :(");
    }
}

- (float)getSpeed {
    return (float)self.clicked / (float)self.duration;
}

+ (NSMutableArray*)log {
    NSUserDefaults *def = [[NSUserDefaults alloc] init];
    NSMutableArray *log = [def objectForKey:@"log"];
    if (nil == log) {
        log = [[NSMutableArray alloc] init];
    }
    return log;
}

+ (NSMutableDictionary*)stats {
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY.MM.dd"];

    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH"];
    
    for (id obj in log) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *item = obj;
            
            int total = [item[1] intValue];
            int time  = [item[2] intValue];
            float speed = (float)total / (float)time;
            NSDate *date = item[0];
            
//            NSString *totalKey = [NSString stringWithFormat:@"%d", total];
            NSString *totalKey = @"42";
            NSString *dayKey = [formatter stringFromDate:date];
            NSString *hourKey = [hourFormatter stringFromDate:date];
            
            // calculate all, not split by totals
            speed = speed * total;
            
            /*
             dayLog [
             //   year  = ...
             //   month = ...
             //   day   = ...
             
                hours = [
                    00 = ...
                    05 = ...
                    12 = ...
                ]
                avg   = ...
                max   = ...
                min   = ...
             ]
             
             */
            
            NSMutableDictionary *totalLog = [stats objectForKey:totalKey];
            if (nil == totalLog) {
                totalLog = [[NSMutableDictionary alloc] init];
                stats[totalKey] = totalLog;
            }

            NSMutableDictionary *dayLog = [totalLog objectForKey:dayKey];
            if (nil == dayLog) {
                dayLog = [[NSMutableDictionary alloc] initWithDictionary: @{@"hours" : [[NSMutableDictionary alloc] init]}];
                totalLog[dayKey] = dayLog;
            }
            
            NSNumber *dayAvg = [dayLog objectForKey:@"avg"];
            NSNumber *dayMax = [dayLog objectForKey:@"max"];
            NSNumber *dayMin = [dayLog objectForKey:@"min"];
            
            if (nil == dayAvg) {
                dayAvg = [NSNumber numberWithFloat:speed];
            } else {
                dayAvg = [NSNumber numberWithFloat:([dayAvg floatValue] + speed) / 2.];
            }
            
            if (nil == dayMax || [dayMax floatValue] < speed) {
                dayMax = [NSNumber numberWithFloat:speed];
            }
 
            if (nil == dayMin || [dayMin floatValue] > speed) {
                dayMin = [NSNumber numberWithFloat:speed];
            }
            
            [dayLog setObject:dayAvg forKey:@"avg"];
            [dayLog setObject:dayMax forKey:@"max"];
            [dayLog setObject:dayMin forKey:@"min"];
            
            NSMutableDictionary *hoursLog = [dayLog objectForKey:@"hours"];
            
            NSNumber *hourAvg = [hoursLog objectForKey:hourKey];
            
            if (nil == hourAvg) {
                hourAvg = [NSNumber numberWithFloat:speed];
            } else {
                hourAvg = [NSNumber numberWithFloat:([hourAvg floatValue] + speed) / 2.];
            }
            
            hoursLog[hourKey] = hourAvg;
            
        }
    }

    return stats;
}

+ (NSMutableDictionary*)statsForDay {
    
    // TODO: не делить на totalsб среднее считать из всех записей за час, только данное количество есть в каждом часу
    // напрмиер, если в каждом часу считали 15 и 42, а в одном или в нескольких, но не во всех, 24, то среднее берется только
    // из 15 и 42,  24 исключается
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    
    for (id obj in log) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *item = obj;
            int total = [item[1] intValue];
            int time  = [item[2] intValue];
            float speed = (float)total / (float)time;
            
            speed = speed * total;

            NSDate *date = item[0];
            
            //            NSLog(@"%d", total);
            
            NSMutableDictionary *dayLog = [stats objectForKey:[NSString stringWithFormat:@"%d", total]];
            NSString *dayKey;
            if (nil == dayLog) {
                dayLog = [[NSMutableDictionary alloc] init];
                dayKey = [NSString stringWithFormat:@"%d", 42];
                stats[dayKey] = dayLog;
            }
            
            dayKey = [formatter stringFromDate:date];
            NSNumber *val = [dayLog objectForKey:dayKey];
            if (nil == val) {
                //                NSLog(@"%f", speed);
                [dayLog setObject:[NSNumber numberWithFloat:speed] forKey:dayKey];
            } else {
                [dayLog setObject:[NSNumber numberWithFloat:(([val floatValue] + speed) / 2.)] forKey:dayKey];
            }
            
        }
    }

    return stats;
}
@end
